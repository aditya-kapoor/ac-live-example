app_folder_name = 'ACLive'
shared_path = "/var/www/apps/#{ app_folder_name }/shared"

worker_processes 4
user 'aditya'
working_directory "/var/www/apps/#{ app_folder_name }/current"
preload_app true
timeout 60

listen "unix:#{ shared_path }/tmp/sockets/unicorn.sock", backlog: 64
pid "#{ shared_path }/tmp/pids/unicorn.pid"

stderr_path "#{ shared_path }/log/unicorn.stderr.log"
stdout_path "#{ shared_path }/log/unicorn.stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end