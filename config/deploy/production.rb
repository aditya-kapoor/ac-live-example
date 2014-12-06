set :stage, :production
set :rails_env, :production

set :branch, 'master'

server '54.69.128.83', user: 'aditya', roles: %w{web app db}