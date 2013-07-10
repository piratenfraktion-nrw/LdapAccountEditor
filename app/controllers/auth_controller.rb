class AuthController < ApplicationController
  before_filter :check_session, :only => :logout


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

    begin
      ldap = ldap_connect(@user[:uid], @user[:userPassword])

      throw "Passwort falsch" unless ldap.bind
      filter = Net::LDAP::Filter.eq("uid", @user[:uid])
      treebase = "dc=piratenfraktion-nrw,dc=de"

      ldap.search(:base => treebase, :filter => filter) do |entry|
        puts "DN: #{entry.dn}"
        @user[:entry] = entry
      end
      session[:user] = @user
      redirect_back_or_default
    rescue
      flash[:error] = "Passwort und/oder Benutzer falsch"
      redirect_to :controller => :auth, :action => :login
    end
  end

  def logout
    session[:user] = nil
    redirect_to :controller => :auth, :action => :login
  end
end
