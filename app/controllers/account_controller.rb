# encoding: utf-8

require 'digest/sha1'
require 'base64'


class AccountController < ApplicationController
  before_filter :check_session

  def show
    @user = session[:user]
    @user_entry = @user[:entry]
    ldap = ldap_connect(@user[:uid], @user[:userPassword])

      filter = Net::LDAP::Filter.eq("uid", @user[:uid])
      treebase = "dc=piratenfraktion-nrw,dc=de"

      ldap.search(:base => treebase, :filter => filter) do |entry|
        puts "DN: #{entry.dn}"
        @user_entry = entry
      end

    render :show
    session[:last_params] = nil
  end

  def update
    @user = session[:user]
    session[:last_params] = nil

    a = Account.new

    begin
      ldap = ldap_connect(@user[:uid], params[:userPassword])
      throw "Passwort falsch" unless ldap.bind

      a.update_attributes(params, @user)

      savereturn = a.save(@user, ldap)

      if savereturn[:success]
        session[:user][:entry] = savereturn[:entry]
        flash[:notice] = "Daten erfolgreich aktualisiert!"
      else
        flash[:error] = "Ungueltiger Wert im Feld " + savereturn[:errorfield]
      end
      
      session[:last_params] = nil
    rescue
      session[:last_params] = params
      flash[:error] = "Passwort stimmt nicht"
    end

    redirect_to :controller => :account, :action => :show
  end
end
