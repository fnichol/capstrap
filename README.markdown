# capstrap

A command to remotely install git, rvm, ruby, and chef-solo using capistrano.

To get started, install capstrap:

    gem install capstrap

capstrap assumes you are operating as *root* so you might want to drop in
your ssh key to root's *authorized_keys*:

    ssh root@zland '(if [ ! -d "${HOME}/.ssh" ]; then \
      mkdir -m 0700 -p ${HOME}/.ssh; fi; \
      cat - >> .ssh/authorized_keys)' < ${HOME}/.ssh/id_dsa.pub

To install a baseline RVM/ruby environment (*ree-1.8.7* is default):

    capstrap ruby root@zland

To use a custom RVM ruby:

    capstrap ruby root@zland --ruby=ruby-1.8.7

To install the *chef* gem:

    capstrap chef root@zland

To install a chef cookbooks repository and chef configuration:

    capstrap solo root@zland \
      --cookbooks-repo=git://github.com/fnichol/chef-repo.git \
      --config-repo=git://github.com/fnichol/chef-dna-spike.git

To override the default cookbooks and configuration paths:

    capstrap solo root@zland \
      --cookbooks-repo=git://github.com/fnichol/chef-repo.git \
      --cookbooks-path=/opt/chef \
      --config-repo=git://github.com/fnichol/chef-dna-spike.git \
      --config-path=/opt/chef/config

To execute a chef configuration (the full monty):

    capstrap execute root@zland \
      --cookbooks-repo=git://github.com/fnichol/chef-repo.git \
      --config-repo=git://github.com/fnichol/chef-dna-spike.git

To set some other crazy configuration (the full monty with cheese):

    capstrap execute root@zland \
      --ruby=ruby-1.8.7 \
      --cookbooks-repo=git://github.com/fnichol/chef-repo.git \
      --cookbooks-path=/opt/chef \
      --config-repo=git://github.com/fnichol/chef-dna-spike.git \
      --config-path=/opt/chef/config

To pull new cookbook/configuration updates and run chef-solo:

    capstrap update root@zland

To get more help:

    capstrap help

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Fletcher Nichol. See LICENSE for details.
