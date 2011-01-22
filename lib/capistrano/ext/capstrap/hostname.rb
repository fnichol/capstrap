module Capstrap
  module Hostname

    def self.load_into(configuration)
      configuration.load do

        namespace :hostname do

          desc "Sets the hostname."
          task :set_hostname do
            unless hostname_correct?(host_name)
              cmd = [
                %{echo "#{host_name}" > /etc/hostname},
                %{chown root:root /etc/hostname},
                %{chmod 0644 /etc/hostname},
                %{start hostname}
              ]
              run cmd.join(" && ")
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capstrap::Hostname.load_into(Capistrano::Configuration.instance)
end
