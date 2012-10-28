# encoding: utf-8

require 'digest/sha1'
require 'base64'


class AccountController < ApplicationController
  before_filter :check_session

  def show
    @user = session[:user]
    @user_entry = @user[:entry]
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
        @user_entry = entry
      end

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
          @user[:userPassword] = params[:newPassword]
        else
          flash[:error] = "Passwort Wiederholung stimmt nicht überein"
        end
      end

      op = []

      op << [:replace, :userPassword, [password]]

      Settings.sections.each do |section|
        section.fields.each do |field|
          if !field.ldap_ignore and field.name != "userPassword"
            if params[field.name.to_sym].present?
              if @user[:entry][field.name.to_sym].nil?
                op << [:add, field.name.to_sym, [params[field.name.to_sym]]]
              else
                op << [:replace, field.name.to_sym, [params[field.name.to_sym]]]
              end
            elsif !params[field.name.to_sym].present? and (@user[:entry][field.name.to_sym].length > 0)
              op << [:delete, field.name.to_sym, nil]
            end
          end
        end
      end

      filter = Net::LDAP::Filter.eq("uid", @user[:uid])
      treebase = "dc=piratenfraktion-nrw,dc=de"

      ldap.search(:base => treebase, :filter => filter) do |entry|
        puts ldap.modify :dn => entry.dn, :operations => op
        puts "DN: #{entry.dn}"
        session[:user][:entry] = entry
        flash[:error] = "Daten erfolgreich aktualisiert!"
      end
    rescue
      flash[:error] = "Passwort stimmt nicht"
    end

    redirect_to :controller => :account, :action => :show
  end
end
