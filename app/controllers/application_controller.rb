class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def check_session
    if session[:user].nil?
      redirect_to :controller => :auth, :action => :login 
      return
    end 
  end
end
