# encoding: utf-8

require 'digest/sha1'
require 'base64'


class AccountController < ApplicationController
  def show
    @user = session[:user]
    @user_entry = @user[:entry]

    render :show
  end

  def update
    @user = session[:user]

    begin
      ldap = Net::LDAP.new :host => Settings.ldap_host,
        :port => Settings.ldap_port,
        :encryption => :simple_tls,
        :auth => {
        :method => :simple,
        :username => "uid=#{@user[:uid]},ou=people,dc=piratenfraktion-nrw,dc=de",
        :password => params[:userPassword]
      }

      throw "Passwort falsch" unless ldap.bind

      password = '{SHA}' + Base64.encode64(Digest::SHA1.digest(params[:userPassword])).chomp!
      if params[:newPassword] != "" 
        if params[:newPassword] == params[:newPasswordRepeat]
          password = '{SHA}' + Base64.encode64(Digest::SHA1.digest(params[:newPassword])).chomp!
        else
          flash[:error] = "Passwort Wiederholung stimmt nicht überein"
        end
      end

      op = [
        [:replace, :nick, [params[:nick]]],
        [:replace, :telephoneNumber, [params[:telephoneNumber]]],
        [:replace, :facsimileTelephoneNumber, [params[:facsimileTelephoneNumber]]],
        [:replace, :roomNumber, [params[:roomNumber]]],
        [:replace, :mobile, [params[:mobile]]],
        [:replace, :displayName, [params[:displayName]]],
        [:replace, :userPassword, [password]]
      ]

      ldap.modify :dn => @user[:entry].dn, :operations => op

      filter = Net::LDAP::Filter.eq("uid", @user[:uid])
      treebase = "dc=piratenfraktion-nrw,dc=de"

      ldap.search(:base => treebase, :filter => filter) do |entry|
        puts "DN: #{entry.dn}"
        session[:user][:entry] = entry
      end
    rescue
      flash[:error] = "Passwort stimmt nicht"
    end

    redirect_to :controller => :account, :action => :show
  end
end
