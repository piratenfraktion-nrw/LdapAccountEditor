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
    session[:last_params] = nil
  end

  def update
    @user = session[:user]
    session[:last_params] = nil

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

      op = []

      Settings.sections.each do |section|
        section.fields.each do |field|
          if !field.ldap_ignore and field.name != "userPassword"
            if params[field.name].present?
              if @user[:entry][field.name].nil?
                op << [:add, field.name, [params[field.name]]]
              else
                op << [:replace, field.name, [params[field.name]]]
              end
            elsif !params[field.name].present? and (@user[:entry][field.name].length > 0)
              op << [:delete, field.name, nil]
            end
          end
        end
      end

      filter = Net::LDAP::Filter.eq("uid", @user[:uid])
      treebase = "dc=piratenfraktion-nrw,dc=de"

      ldap.search(:base => treebase, :filter => filter) do |entry|
        puts ldap.modify :dn => entry.dn, :operations => op
        puts op.inspect
        puts "DN: #{entry.dn}"
        session[:user][:entry] = entry
        flash[:error] = "Daten erfolgreich aktualisiert!"
      end
      session[:last_params] = nil
    rescue
      session[:last_params] = params
      flash[:error] = "Passwort stimmt nicht"
    end

    redirect_to :controller => :account, :action => :show
  end
end
