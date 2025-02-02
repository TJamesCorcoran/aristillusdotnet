# frozen_string_literal: true

set :rvm_ruby_string, :local
set :rvm_custom_path, '/usr/share/rvm'

# before 'deploy', 'rvm:install_rvm'
# before 'deploy', 'rvm:install_ruby'

# config valid for current version and patch releases of Capistrano
lock '~> 3.19.1'

set :application, 'aristillus_dot_net'
set :repo_url, 'git@git.aristillus.net:/home/git/repositories/aristillus_src.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# no default; specify only in production.rb, staging.rb, etc
# set :deploy_to, "/var/www/"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
