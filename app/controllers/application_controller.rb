class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def require_token(name)
    token = ENV["#{name.upcase}_TOKEN"]
    render status: 403, plain: 'Forbidden' unless token && token == params[:token]
  end
end
