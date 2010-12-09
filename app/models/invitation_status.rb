class InvitationStatus
  @@ACCEPTED = 1
  @@EXPIRED = 2
  @@WAITING = 3
  
  def self.accepted
    @@ACCEPTED
  end
  def self.expired
    @@EXPIRED
  end
  def self.waiting
    @@WAITING
  end
end