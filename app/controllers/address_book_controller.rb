class AddressBookController < ApplicationController
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

    throw "error" unless ldap.bind

    filter = Net::LDAP::Filter.eq("objectClass", "inetOrgPerson")
    treebase = "dc=piratenfraktion-nrw,dc=de"

    @users = []
    ldap.search(:base => treebase, :filter => filter) do |entry|
      puts "DN: #{entry.dn}"
      @users << entry
    end


    render :show
  end
end
