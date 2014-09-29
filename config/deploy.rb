# config valid only for Capistrano 3.2.1
lock '3.2.1'

set :application, 'workset-builder'
set :repo_url, 'https://github.com/htrc/HTRC-UI-WorksetBuilder.git'

# Capistrano should skip gems which only apply to development an test when running bundle install
set :bundle_without, [:development, :test]

# ping url for use during capistrano deploy/restart
set :ping_url, "http://localhost:9443/#{fetch(:application)}"

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'
# not set here because it is different per environment

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/htrc.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# deploy with Phusian Passenger restart code
namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
# Your restart mechanism here, for example:

      execute "mkdir -p #{release_path.join('tmp')}"
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart


  desc 'Warm up the application by pinging it, so enduser wont have to wait'
  task :ping do
    on roles(:app), in: :sequence, wait: 5 do
      execute "curl -s -D - #{fetch(:ping_url)} -o /dev/null"
    end
  end

  after :restart, :ping


  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
