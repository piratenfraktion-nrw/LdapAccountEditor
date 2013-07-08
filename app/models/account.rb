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
end
