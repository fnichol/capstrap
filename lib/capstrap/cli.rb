module Capstrap
  class CLI < Thor
    
    def initialize(*)
      super
    end
    
    default_task :help
    
    desc "ruby HOST", "Install an RVM ruby on remote SSH host HOST"
    method_option "ruby", :type => :string, :banner => 
      "Version of ruby to install.", :default => "ree-1.8.7"
    method_option "default", :type => :boolean, :banner => 
      "Set this ruby to be RVM default."
    def ruby(ssh_host)
      @ssh_host = ssh_host
      abort ">> HOST must be set" unless @ssh_host

      config.find_and_execute_task "rvm:install:#{options[:ruby]}"
      if options[:default]
        config.find_and_execute_task "rvm:default:#{options[:ruby]}"
      end
    end

    desc "chefsolo HOST", "Install chef solo on remote SSH host HOST"
    method_option "ruby", :type => :string, :banner => 
      "Version of ruby to install.", :default => "ree-1.8.7"
    def chefsolo(ssh_host)
      @ssh_host = ssh_host
      abort ">> HOST must be set" unless @ssh_host

      invoke :ruby, [ssh_host], :ruby => options[:ruby], :default => true
      config.find_and_execute_task "chef:install:solo"
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
  end
end
