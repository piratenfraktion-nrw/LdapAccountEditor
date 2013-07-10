class AddressBookController < ApplicationController
  before_filter :check_session

  def show
    @user = session[:user]
    @user_entry = @user[:entry]

    ldap = ldap_connect(@user[:uid], @user[:userPassword])

    throw "error" unless ldap.bind

    filter = Net::LDAP::Filter.eq("objectClass", "piratenfraktion")
    treebase = "dc=piratenfraktion-nrw,dc=de"

    @users = []
    ldap.search(:base => treebase, :filter => filter) do |entry|
      puts "DN: #{entry.dn}"
      @users << entry
    end


    render :show
  end
end
