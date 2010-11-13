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
    method_option "ruby", :type => :string, :banner => 
      "Version of ruby to install.", :default => "ree-1.8.7"
    method_option "default", :type => :boolean, :banner => 
      "Set this ruby to be RVM default."
    def ruby(ssh_host)
      @ssh_host = ssh_host
      abort ">> HOST must be set" unless @ssh_host

      setup_config options

      config.find_and_execute_task "rvm:install:#{options[:ruby]}"
      if options[:default]
        config.find_and_execute_task "rvm:default:#{options[:ruby]}"
      end
    end

    desc "chef HOST", "Install chef gem on remote SSH host HOST"
    method_option "ruby", :type => :string, :banner => 
      "Version of ruby to install.", :default => "ree-1.8.7"
    def chef(ssh_host)
      @ssh_host = ssh_host
      abort ">> HOST must be set" unless @ssh_host

      setup_config options

      invoke :ruby, [ssh_host], :ruby => options[:ruby], :default => true
      config.find_and_execute_task "chef:install:lib"
    end

    desc "solo HOST", "Install chef cookbooks & config on remote SSH host HOST"
    method_option "ruby", :type => :string, 
      :banner => "Version of ruby to install.",
      :default => "ree-1.8.7",
      :aliases => "-r"
    method_option "cookbooks-repo", :type => :string,
      :banner => "Chef cookbooks git repository URL.",
      :aliases => "-c"
    method_option "cookbooks-path", :type => :string,
      :banner => "Install path to chef cookbooks git repository.",
      :default => "/var/chef-solo",
      :aliases => "-p"
    method_option "cookbooks-rake-update", :type => :boolean, :banner =>
      "Run rake update vs. git submodule init/update when updating cookbooks repo",
      :default => false,
      :aliases => "-u"
    method_option "config-repo", :type => :string,
      :banner => "Chef configuration git repository URL.",
      :aliases => "-C"
    method_option "config-path", :type => :string,
      :banner => "Install path to chef configuration git repository.",
      :default => "/etc/chef",
      :aliases => "-P"
    method_option "config-rake-update", :type => :boolean, :banner =>
      "Run rake update vs. git submodule init/update when updating config repo",
      :default => false,
      :aliases => "-U"
    def solo(ssh_host)
      @ssh_host = ssh_host
      abort ">> HOST must be set" unless @ssh_host

      setup_config options

      unless options["cookbooks-repo"]
        abort ">> --cookbooks-repo=<git_url> must be set" 
      end
      unless options["config-repo"]
        abort ">> --config-repo=<git_url> must be set"
      end

      invoke :chef, [ssh_host], :ruby => options[:ruby], :default => true
      config.find_and_execute_task "chef:install:cookbooks"
      config.find_and_execute_task "chef:install:config"
    end

    desc "execute HOST", "Executes chef solo config on remote SSH host HOST"
    method_option "ruby", :type => :string, 
      :banner => "Version of ruby to install.",
      :default => "ree-1.8.7",
      :aliases => "-r"
    method_option "cookbooks-repo", :type => :string,
      :banner => "Chef cookbooks git repository URL.",
      :aliases => "-c"
    method_option "cookbooks-path", :type => :string,
      :banner => "Install path to chef cookbooks git repository.",
      :default => "/var/chef-solo",
      :aliases => "-p"
    method_option "cookbooks-rake-update", :type => :boolean, :banner =>
      "Run rake update vs. git submodule init/update when updating cookbooks repo",
      :default => false,
      :aliases => "-u"
    method_option "config-repo", :type => :string,
      :banner => "Chef configuration git repository URL.",
      :aliases => "-C"
    method_option "config-path", :type => :string,
      :banner => "Install path to chef configuration git repository.",
      :default => "/etc/chef",
      :aliases => "-P"
    method_option "config-rake-update", :type => :boolean, :banner =>
      "Run rake update vs. git submodule init/update when updating config repo",
      :default => false,
      :aliases => "-U"
    def execute(ssh_host)
      @ssh_host = ssh_host
      abort ">> HOST must be set" unless @ssh_host

      setup_config options

      unless options["cookbooks-repo"]
        abort ">> --cookbooks-repo=<git_url> must be set" 
      end
      unless options["config-repo"]
        abort ">> --config-repo=<git_url> must be set"
      end

      invoke :solo, [ssh_host], :ruby => options[:ruby], :default => true,
        :"cookbooks-repo" => options["cookbooks-repo"],
        :"cookbooks-path" => options["cookbooks-path"],
        :"config-repo" => options["config-repo"],
        :"config-path" => options["config-path"]
      config.find_and_execute_task "chef:execute:solo"
    end

    desc "update HOST", "Updates and executes chef solo on remote SSH host HOST"
    method_option "ruby", :type => :string,
      :banner => "Version of ruby to install.",
      :default => "ree-1.8.7",
      :aliases => "-r"
    method_option "cookbooks-path", :type => :string,
      :banner => "Install path to chef cookbooks git repository.",
      :default => "/var/chef-solo",
      :aliases => "-p"
    method_option "cookbooks-rake-update", :type => :boolean, :banner =>
      "Run rake update vs. git submodule init/update when updating cookbooks repo",
      :default => false,
      :aliases => "-u"
    method_option "config-path", :type => :string,
      :banner => "Install path to chef configuration git repository.",
      :default => "/etc/chef",
      :aliases => "-P"
    method_option "config-rake-update", :type => :boolean, :banner =>
      "Run rake update vs. git submodule init/update when updating config repo",
      :default => false,
      :aliases => "-U"
    def update(ssh_host)
      @ssh_host = ssh_host
      abort ">> HOST must be set" unless @ssh_host

      setup_config options

      config.find_and_execute_task "chef:execute:update"
    end

  private
  
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

    def setup_config(options)
      [
        {:sym => :ruby,           :opt => "ruby"},
        {:sym => :cookbooks_repo, :opt => "cookbooks-repo"},
        {:sym => :cookbooks_path, :opt => "cookbooks-path"},
        {:sym => :config_repo,    :opt => "config-repo"},
        {:sym => :config_path,    :opt => "config-path"}
      ].each do |var|
        config.set(var[:sym], options[var[:opt]]) if options[var[:opt]]
      end
    end
  end
end
