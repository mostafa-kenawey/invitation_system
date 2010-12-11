class RegistrationType
  @@REGISTRATION_OPEN = 1
  @@REGISTRATION_WITH_INVITATION = 2
  @@REGISTRATION_CLOSE = 3
  
  def self.registration_open
    @@REGISTRATION_OPEN
  end
  def self.registration_with_invitation
    @@REGISTRATION_WITH_INVITATION
  end
  def self.registration_close
    @@REGISTRATION_CLOSE
  end
end