class Invitation < ActiveRecord::Base
  belongs_to :users
  
  validates_presence_of :user_id, :invited_email, :expiry_date, :inviter_name
  validates_format_of :invited_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Please check the e-mail address"[:check_email_message]
  validates_uniqueness_of :invitation_key  
  
  before_save :create_invitation_key
  
  def create_invitation_key
    digval = Time.now.to_s + self.invited_email
    self.invitation_key  = Digest::SHA1.hexdigest(digval)   
  end
 
  def accept!(invited_id)
    self.status = 1 #invitation accepted 
    self.invited_id = invited_id
    self.save!
  end
  
  def invited
    User.find self.invited_id
  end
  
  def invitation_status
    if self.status == true
      return InvitationStatus.accepted
    elsif self.expiry_date < Date.today
      return InvitationStatus.expired
    else
      return InvitationStatus.waiting      
    end
  end
  
end
