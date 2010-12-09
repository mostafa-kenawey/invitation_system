class InvitationMailer < ActionMailer::Base
  def invitation(invitation , domain)
    @subject    = "Invitation"
    @body       = {:domain => domain, :invitation=>invitation}
    @recipients = invitation.invited_email
    @from       = 'noreply@noreply.com'
    @sent_on    = Time.now.utc
    @content_type = "text/html"
  end
end