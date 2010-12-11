module Capstrap
  class CLI < Thor
    
    def initialize(*)
      super
    end
    
    default_task :help

    desc "version", "Version of capstrap"
    def version
      puts "capstrap v#{Capstrap::VERSION}"
    end
    
    desc "ruby HOST", "Install an RVM ruby on remote SSH host HOST"
    def ruby(ssh_host)
      track_time do
        @ssh_host = ssh_host
        setup_config options
        exec_ruby
      end
    end

    desc "chef HOST", "Install chef gem on remote SSH host HOST"
    def chef(ssh_host)
      track_time do
        @ssh_host = ssh_host
        setup_config options
        exec_chef
      end
    end

    desc "solo HOST", "Install chef cookbooks & config on remote SSH host HOST"
    def solo(ssh_host)
      track_time do
        @ssh_host = ssh_host
        setup_config options
        assert_repos_set
        exec_solo
      end
    end

    desc "execute HOST", "Executes chef solo config on remote SSH host HOST"
    def execute(ssh_host)
      track_time do
        @ssh_host = ssh_host
        setup_config options
        assert_repos_set
        exec_execute
      end
    end

    desc "update HOST", "Updates and executes chef solo on remote SSH host HOST"
    def update(ssh_host)
      track_time do
        @ssh_host = ssh_host
        setup_config options
        exec_update
      end
    end

    [:ruby, :chef, :solo, :execute, :update].each do |task|
      method_option "config", :for => task, :type => :string, 
        :desc => "Read from alternative configuration.",
        :default => File.join(ENV['HOME'], ".capstraprc"),
        :aliases => "-f"

      method_option "ruby", :for => task, :type => :string, 
        :desc => "Version of ruby to install.", 
        :default => "ree-1.8.7"
    end

    [:chef, :solo, :execute, :update].each do |task|
      method_option "cookbooks-path", :for => task, :type => :string,
        :desc => "Install path to chef cookbooks git repository.",
        :default => "/var/chef-solo",
        :aliases => "-p"

      method_option "cookbooks-rake-update", :for => task, :type => :boolean,
        :desc => "Run rake update vs. git submodule init/update when updating cookbooks repo",
        :default => false,
        :aliases => "-u"

      method_option "config-path", :for => task, :type => :string,
        :desc => "Install path to chef configuration git repository.",
        :default => "/etc/chef",
        :aliases => "-P"

      method_option "config-rake-update", :for => task, :type => :boolean,
        :desc => "Run rake update vs. git submodule init/update when updating config repo",
        :default => false,
        :aliases => "-U"
    end

    [:chef, :solo, :execute].each do |task|
      method_option "cookbooks-repo", :for => task, :type => :string,
        :desc => "Chef cookbooks git repository URL.",
        :aliases => "-c"

      method_option "config-repo", :for => task, :type => :string,
        :desc => "Chef configuration git repository URL.",
        :aliases => "-C"
    end

  private

    def assert_repos_set
      unless config.fetch(:cookbooks_repo)
        abort ">> --cookbooks-repo=<git_url> must be set" 
      end
      unless config.fetch(:config_repo)
        abort ">> --config-repo=<git_url> must be set"
      end
    end

    def exec_ruby
      config.find_and_execute_task "rvm:install:#{config.fetch(:ruby)}"
      config.find_and_execute_task "rvm:default:#{config.fetch(:ruby)}"
    end

    def exec_chef
      exec_ruby
      config.find_and_execute_task "chef:install:lib"
    end

    def exec_solo
      exec_chef
      config.find_and_execute_task "chef:install:cookbooks"
      config.find_and_execute_task "chef:install:config"
    end

    def exec_execute
      exec_solo
      config.find_and_execute_task "chef:execute:solo"
    end

    def exec_update
      config.find_and_execute_task "chef:execute:update"
    end
  
    def config
      @config ||= prep_config
    end
    
    def prep_config
      config = Capistrano::Configuration.new
      config.logger.level = Capistrano::Logger::TRACE
      config.role(:remote_host, @ssh_host)
      
      Capstrap::Apt.load_into(config)
      Capstrap::Core.load_into(config)
      Capstrap::RVM.load_into(config)
      Capstrap::Chef.load_into(config)

      config
    end

    def setup_config(cli_options)
      abort ">> HOST must be set" unless @ssh_host

      options = Hash.new
      options.merge!(cli_options)
      if File.exists?(options["config"])
        options.merge!(YAML::load_file(options["config"])) 
      end

      [
        {:sym => :ruby,                   :opt => "ruby"},
        {:sym => :cookbooks_repo,         :opt => "cookbooks-repo"},
        {:sym => :cookbooks_path,         :opt => "cookbooks-path"},
        {:sym => :config_repo,            :opt => "config-repo"},
        {:sym => :config_path,            :opt => "config-path"}
      ].each do |var|
        config.set(var[:sym], options[var[:opt]]) if options[var[:opt]]
      end

      # booleans
      [
        {:sym => :cookbooks_rake_update,  :opt => "cookbooks-rake-update"},
        {:sym => :config_rake_update,     :opt => "config-rake-update"}
      ].each do |var|
        config.set(var[:sym], options[var[:opt]])
      end
    end

    def track_time(&block)
      start = Time.now
      yield
      elapsed = Time.now - start
      if elapsed < 60.0
        puts "\n\n  * Elapsed time: #{(Time.now - start)} seconds.\n"
      else
        puts "\n\n  * Elapsed time: #{(Time.now - start) / 60.0} minutes.\n"
      end
    end
  end
end
