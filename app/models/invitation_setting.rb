class InvitationSetting < ActiveRecord::Base
  def self.registeration_type
    (InvitationSetting.find_by_key("registeration_type").try :value).to_i
  end
  
  def self.validity_period
    (InvitationSetting.find_by_key("validity_period").try :value).to_i
  end
  
  def self.email_subject
    InvitationSetting.find_by_key("email_subject").try :value
  end
  
  def self.email_from
    InvitationSetting.find_by_key("email_from").try :value
  end
end
