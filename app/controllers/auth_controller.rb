class AuthController < ApplicationController
  def login
    if session[:user].nil?
      render :login
    else
      redirect_to :controller => :account, :action => :show
    end
  end

  def auth
    @user = {
      :uid => params[:uid],
      :userPassword => params[:userPassword]
    }

    ldap = Net::LDAP.new :host => Settings.ldap_host,
      :port => Settings.ldap_port,
      :encryption => :simple_tls,
      :auth => {
      :method => :simple,
      :username => "uid=#{@user[:uid]},ou=people,dc=piratenfraktion-nrw,dc=de",
      :password => @user[:userPassword]
    }

    filter = Net::LDAP::Filter.eq("uid", @user[:uid])
    treebase = "dc=piratenfraktion-nrw,dc=de"
    
    ldap.search(:base => treebase, :filter => filter) do |entry|
      puts "DN: #{entry.dn}"
      @user[:entry] = entry
    end
    session[:user] = @user
    redirect_to :controller => :account, :action => :show
  end

  def logout
    session[:user] = nil
    redirect_to :controller => :auth, :action => :login
  end
end
