module Capstrap
  module Hostname

    def self.load_into(configuration)
      configuration.load do

        namespace :hostname do

          desc "Sets the hostname."
          task :set_hostname do
            if exists?(:host_name)
              hname = fetch(:host_name)
            else
              hname = capture(%{hostname}).chomp
            end

            unless hostname_correct?(hname)
              cmd = [
                %{echo "#{hname}" > /etc/hostname},
                %{chown root:root /etc/hostname},
                %{chmod 0644 /etc/hostname},
                %{start hostname}
              ]
              run cmd.join(" && ")
            end
          end

          desc "Sets the full qualified domain name."
          task :set_fqdn do
            begin
              current_fqdn = capture(%{hostname -f}).chomp
            rescue
              current_fqdn = "fubarname.fubardomain"
            end

            if exists?(:host_name)
              hname = fetch(:host_name)
            else
              hname = current_fqdn.split('.').shift
            end

            if exists?(:domain_name)
              dname = fetch(:domain_name)
            else
              dname = current_fqdn.split('.').drop(1).join('.')
            end

            unless fqdn_correct?(hname, dname, "127.0.1.1")
              run <<-UPDATE_HOSTS
                if egrep -q '^127.0.1.1[[:space:]]' /etc/hosts >/dev/null ; then
                  perl -pi -e 's|^(127.0.1.1[[:space:]]+).*$|\$1#{hname}.#{dname} #{hname}|' /etc/hosts;
                else
                  perl -pi -e 's|^(127\.0\.0\.1[[:space:]]+.*)$|\$1\n127.0.1.1 #{hname}.#{dname} #{hname}|' /etc/hosts;
                fi;
              UPDATE_HOSTS
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
