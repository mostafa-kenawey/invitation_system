class InvitationMailer < ActionMailer::Base
  def invitation(invitation , domain)
    @subject    = InvitationSetting.email_subject
    @body       = {:domain => domain, :invitation=>invitation}
    @recipients = invitation.invited_email
    @from       = InvitationSetting.email_from
    @sent_on    = Time.now.utc
    @content_type = "text/html"
  end
end