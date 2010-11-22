require 'ostruct'

module Capstrap
  module RVM

    RUBIES = [
      OpenStruct.new(:ruby => "ruby-1.8.7", :title => "MRI 1.8.7"),
      OpenStruct.new(:ruby => "ruby-1.9.2", :title => "MRI 1.9.2"),
      OpenStruct.new(:ruby => "ree-1.8.7", :title => "REE 1.8.7"),
    ]
    
    def self.load_into(configuration)
      configuration.load do
        namespace :rvm do
          namespace :install do

            desc "Installs system-wide rvm from github."
            task :system_base do
              unless rvm_installed?
                run %{bash < <( curl -L http://bit.ly/rvm-install-system-wide )},
                  :shell => "bash"
              end
            end

            RUBIES.each do |r|
              desc "Installs latest #{r.title} ruby."
              task r.ruby do
                unless rvm_installed?
                  apt.install.rvm_depends
                  rvm.install.system_base
                end
                unless ruby_installed?(r.ruby)
                  apt.install.mri_depends
                  rvm_run %{#{r.ruby} install}
                end
              end
            end
          end

          namespace :default do
            
            RUBIES.each do |r|
              desc "Sets #{r.title} as default ruby."
              task :"#{r.ruby}" do
                rvm_run %{#{r.ruby} --default}
              end
            end
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capstrap::RVM.load_into(Capistrano::Configuration.instance)
end
