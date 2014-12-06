# config valid only for current version of Capistrano
lock '3.3.3'

set :application, 'ACLive'
set :repo_url, 'git@github.com:aditya-kapoor/ac-live-example.git'

set :deploy_to, '/var/www/apps/ACLive'
set :scm, :git
set :format, :pretty

set :linked_files, %w{config/database.yml config/secrets.yml}

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}

set :keep_releases, 5

namespace :deploy do
  after :publishing, :restart

  after :restart, :unicorn_restart do
    on roles(:web), in: :parallel do
      within current_path do
        with rails_env: fetch(:rails_env) do
          Rake::Task[:'database:migrate'].invoke
          Rake::Task[:'unicorn:hard_restart'].invoke
          Rake::Task[:'delayed_job:restart'].invoke
        end
      end
    end
  end
end

namespace :unicorn do
  task :hard_restart do
    Rake::Task[:'unicorn:stop'].invoke
    Rake::Task[:'unicorn:start'].invoke
  end

  desc 'start unicorn'
  task :start do
    on roles(:app), in: :parallel do
      within current_path do
        execute :bundle, :exec, "unicorn_rails -c config/unicorn.rb -D -E #{ fetch(:rails_env) }"
      end
    end
  end

  desc 'stop unicorn'
  task :stop do
    on roles(:app), in: :parallel do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, "kill -s QUIT `cat #{shared_path}/tmp/pids/unicorn.pid`"
        end
      end
    end
  end

  desc 'restart unicorn'
  task :restart do
    on roles(:app), in: :parallel do
      within current_path do
        execute "kill -s USR2 `cat #{shared_path}/tmp/pids/unicorn.pid`"
      end
    end
  end
end

