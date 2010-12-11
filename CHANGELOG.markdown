# 0.3.3

  * Add call to apt-get update pre-package install
  * Set ruby as rvm default by default (of course)
  * Record the elapsed time on a capstrap execution.

# 0.3.2

  * Install chef gem to rvm default gemset rather than @global
  * Install chef gem with --no-rdoc --no-ri

# 0.3.1

  * Remove rvm_sugar installation (customization overkill).

# 0.3.0

  * Add --config flag and read config from ~/.capstraprc by default.
  * Refactor method_option blocks on tasks (dry it up).

# 0.2.2

  * Add task method options for overriding git init/update behavior
  * Add version task
  * Update method_option from :banner to :desc (oops)
  * Handle git submodule init/update or rake update strategies

# 0.2.1

  * Add `update` task to pull new cookbook and configuration updates and re-run chef
# 0.2.0

  * Rename `chefsolo` task to chef
  * Add `solo` task to install chef cookbook and configuration repositories
  * Add `execute` task to run chef-solo once environment is prepared
  * Refactorings of chef capistrano recipes

# 0.1.0

  * Initial release
