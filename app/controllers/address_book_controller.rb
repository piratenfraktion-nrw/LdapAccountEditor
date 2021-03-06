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

    filter = Net::LDAP::Filter.eq("objectClass", "piratenfraktion")
    treebase = "dc=piratenfraktion-nrw,dc=de"

    @users = []
    ldap.search(:base => treebase, :filter => filter) do |entry|
      puts "DN: #{entry.dn}"
      @users << entry if entry[:uid].length > 0
    end

    respond_to do |format|
      format.html
      format.pdf do
        render  :pdf => "piratenfraktion_adressbuch",
                :print_media_type => false,
                :book => false,
                :layout => 'layouts/pdf.html.erb',
                :no_background => true,
                :grayscale => false,
                :lowquality => false,
                :orientation => 'Landscape'
      end
    end
  end
end
