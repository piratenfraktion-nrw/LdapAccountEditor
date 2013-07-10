class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def check_session
    if session[:user].nil?
      session[:return_to] = request.url 
      redirect_to :controller => :auth, :action => :login 
      return
    end 
  end

  def redirect_back_or_default
    if session[:return_to].nil?
      redirect_to :controller => :account, :action => :show
    else
      redirect_to session[:return_to]
    end
    session[:return_to] = nil
  end

  def ldap_connect(username, password)
    return Net::LDAP.new :host => Settings.ldap_host,
        :port => Settings.ldap_port,
        :encryption => :simple_tls,
        :auth => {
        :method => :simple,
        :username => "uid=#{username},ou=people,dc=piratenfraktion-nrw,dc=de",
        :password => password
      }
  end
end
