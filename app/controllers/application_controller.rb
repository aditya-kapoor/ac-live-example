class ApplicationController < ActionController::Base
  include ActionController::Live
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    response.header['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write 'hello world\n'
      sleep 1
    }
  ensure
    response.stream.close
  end
end
