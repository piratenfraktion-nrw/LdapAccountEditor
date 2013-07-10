class Account
  include ActiveModel::Model

  def initialize
    Settings.sections.each do |section|
      section.fields.each do |field|
        singleton_class.class_eval do; attr_accessor field.name; end
        singleton_class.class_eval do; validates_presence_of field.name; end if field.required
      end
    end
  end

  def update_attributes(params, user)
    @op = []

    Settings.sections.each do |section|
      section.fields.each do |field|
        if !field.ldap_ignore and field.name != "userPassword"
          if params[field.name].present?
            if user[:entry][field.name].nil?
              @op << [:add, field.name, [params[field.name]]]
            else
              @op << [:replace, field.name, [params[field.name]]]
            end
          elsif !params[field.name].present? and (user[:entry][field.name].length > 0)
            @op << [:delete, field.name, nil]
          end
        end
      end
    end
  end

  def save(user, ldap)
      filter = Net::LDAP::Filter.eq("uid", user[:uid])
      treebase = "dc=piratenfraktion-nrw,dc=de"

      ldap.search(:base => treebase, :filter => filter) do |entry|
        puts ldap.modify :dn => entry.dn, :operations => @op
        puts @op.inspect
        puts "DN: #{entry.dn}"
        return {:success => true, :entry => entry} 
      end
  end
end
