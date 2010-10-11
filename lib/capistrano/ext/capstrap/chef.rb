module Capstrap
  module Chef
    
    def self.load_into(configuration)
      configuration.load do
        
        namespace :chef do
          namespace :install do
            
            desc "Installs chef solo"
            task :solo do
              cmd = [
                %{use default@global},
                %{gem install chef}
              ]
              rvm_run cmd.join(" && ")
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capstrap::Chef.load_into(Capistrano::Configuration.instance)
end
