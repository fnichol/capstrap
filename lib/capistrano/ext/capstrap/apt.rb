module Capstrap
  module Apt

    APT_RVM_PKGS = %w{sed grep tar gzip bzip2 bash curl git-core}
    
    APT_MRI_AND_REE_PKGS = %w{build-essential bison openssl libreadline5 
      libreadline-dev zlib1g zlib1g-dev libssl-dev vim libsqlite3-0 
      libsqlite3-dev sqlite3 libxml2-dev subversion autoconf ssl-cert}

    def self.load_into(configuration)
      configuration.load do

        def self.task_name(pkg)
          pkg.gsub(/-/, "_").to_sym
        end

        namespace :apt do
          desc "Resynchronizes the package index files."
          task :update do
            unless @updated
              apt_update
              @updated = true
            end
          end

          namespace :install do
            desc "Installs packages for running RVM"
            task :rvm_depends do
              apt_install APT_RVM_PKGS.join(" ")
            end
            
            desc "Installs packages for running MRI/REE."
            task :mri_depends do
              apt_install APT_MRI_AND_REE_PKGS.join(" ")
            end
            
            desc "Installs all packages via apt-get."
            task :default do
              rvm_depends
              mri_depends
            end
          end
        end

        before "apt:install:rvm_depends", "apt:update"
        before "apt:install:mri_depends", "apt:update"
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capstrap::Apt.load_into(Capistrano::Configuration.instance)
end
