##
# Runs a remote if condition and returns true/false.
#
# @param [String] conditional to be tested
# @return [true, false] whether or not the conditional passes
def cmd_if(test, rvm=false)
  load_rvm = ""
  load_rvm = "#{rvm_env} " if rvm
  r = capture %{#{load_rvm}if #{test} ; then echo true; else echo false; fi}, 
    :shell => "bash"
  puts "  * Result is: #{r.to_s}"
  if r.to_s =~ /true/
    true
  else
    false
  end
end

##
# Runs a remote if test condition and returns true/false
#
# @param [String] test to be tested
# @return [true, false] whether or not the test passes
def cmd_test(test, rvm=false)
  cmd_if %{[ #{test} ]}, rvm
end

##
# Checks if a package is installed on the remote host.
#
# @param [String] package name to check
# @return [true, false] whether or not the package is installed
def pkg_installed?(pkg)
  cmd_if %{dpkg-query --showformat='${Essential}\n' --show '#{pkg}' > /dev/null 2>&1}
end

##
# Installs a package via apt-get.
#
# @param [String] package name to install
def apt_install(pkg, check=false)
  if check && pkg_installed?(pkg)
    info %{Package "#{pkg}" is already installed, skipping.}
  else
    run %{apt-get install -y #{pkg}}
  end
end

##
# Updates package repository via apt-get.
def apt_update
  run %{apt-get update -y}
end

def rvm_env
  %{[[ -s "/usr/local/lib/rvm" ]] && source /usr/local/lib/rvm; }
end

##
# Runs a remote command in an RVM aware bubble.
#
# @param [String] command to run
def rvm_run(cmd)
  run %{#{rvm_env} rvm #{cmd}}, :shell => "bash"
end

##
# Checks if RVM is installed on the remote host.
#
def rvm_installed?
  cmd_test %{-s "/usr/local/lib/rvm"}
end

##
# Checks if an RVM ruby is installed on the remote host.
#
# @param [String] ruby string
def ruby_installed?(ruby)
  cmd_if %{rvm list strings | grep -q "#{ruby}" >/dev/null}, true
end

##
# Checks if the chef gem is installed on the remote host.
#
def chef_installed?
  cmd_if %{rvm use #{ruby}@global >/dev/null && gem list --no-versions | grep -q "^chef$" >/dev/null}, true
end


##
# Checks if chef cookbook repo is installed on the remote host.
#
def cookbooks_repo_installed?
  cmd_test %{-d "#{cookbooks_path}"}
end

##
# Checks if chef config repo is installed on the remote host.
#
def config_repo_installed?
  cmd_test %{-d "#{config_path}"}
end

def update_cmd
  if cookbooks_rake_update
    %{rake update}
  else
    %{git submodule init && git submodule update}
  end
end

##
# Prints an information message.
#
# @param [String] message to display
def info(msg)
  puts "\n ==> #{msg}"
end

##
# Prints a message intended to catch attention.
#
# @param [String] message to display
def banner(msg)
  puts "\n  #{'*' * (msg.size + 6)}"
  puts "  *  #{msg}  *"
  puts "  #{'*' * (msg.size + 6)}\n"
end


module Capstrap
  module Core

    def self.load_into(configuration)
      configuration.load do

        namespace :core do
          desc "Installs entire toolchain."
          task :default do
            unless rvm_installed?
              apt.install.rvm_depends
              rvm.install.system_base
            end
            apt.install.mri_depends
            rvm.install.ree187
            rvm.default.ree187
          end
        end
      end
    end
  end
end

if Capistrano::Configuration.instance
  Capstrap::Core.load_into(Capistrano::Configuration.instance)
end
