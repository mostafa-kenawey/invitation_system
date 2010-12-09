class InvitationSetting < ActiveRecord::Base
  def self.registeration_type
    (InvitationSetting.find_by_key("registeration_type").try :value).to_i
  end
  
  def self.validity_period
    (InvitationSetting.find_by_key("validity_period").try :value).to_i
  end
end
