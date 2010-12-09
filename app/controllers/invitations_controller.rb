class InvitationsController < InvitationApplicationController  
  before_filter :is_invitations_enabled?, :only => [:new, :create, :resend]
  
  def index
    @user = User.find(params[:user_id])
    @invitations = @user.invitations
  end
  
  def new
    current_user.invitations_count = current_user.current_invitations_count
    if current_user.invitations_count <= 0 or (current_user.invitations_expiration and current_user.invitations_expiration <= Date.today)
      respond_to do |format|
        format.html do
          if current_user.invitations_expiration and current_user.invitations_expiration <= Date.today
            msg = "Sorry, Your invitations has been expired."
          else
            msg = "Sorry, You can't invite more users." 
          end          
          flash[:alert] = msg
          redirect_to user_invitations_path(current_user.id)
        end
      end
    end
  end
  
  def create
    @user = User.find(current_user.id)
    
    emails = {}
    emails = params[:emails] if !params[:emails].blank?
    emails.delete_if { |key, value| value.blank? }
    
    msg = []
    msg << "Please add at least one valid email address" if emails.empty?
    msg << "Can't send invitation more than your maximum limit" if emails.length > @user.current_invitations_count
    msg << "Please type the sender name" if params[:inviter_name].blank?
    msg << "Please type the invitation message" if params[:body].blank?
    
    emails.each do |key, email|
      if !(email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
        msg << "Email (#{email}) is not valid email address."
      elsif User.exists?(['email = ?', email])
        msg << "The email (#{email}) already exists"
      elsif user_invitation = Invitation.find_by_invited_email(email)
        case user_invitation.invitation_status
          when InvitationStatus.waiting
            msg << "An invitation has been sent to the mail (#{email}), and waiting for reply."        
          when InvitationStatus.expired
            msg << "An invitation has been sent to the mail (#{email}), and the invitation was expired."
          when InvitationStatus.accepted
            msg << "An invitation has been sent to the mail (#{email}), and the invitation was accepted."
        end
      end      
    end
    
    if msg.size > 0
      flash[:alert] = msg.join("<br/>")
      render :action => 'new'
      msg = []
      return false
    end
    
    invitations_list = []
    emails_list = []
    emails.each do |key, email|
      invitation = Invitation.new(:invited_email => email,
                                      :body => params[:body],
                                      :inviter_name => params[:inviter_name],
                                      :user_id => current_user.id,
                                      :expiry_date => Date.today + InvitationSetting.validity_period)
        
      if invitation.valid?
        invitations_list << invitation if !emails_list.include?(email)
        emails_list << email
      else
        msg << "Email (#{email}) is not valid."
      end
    end
    
    if msg.size > 0
      flash[:alert] = msg.join("<br/>")
      render :action => 'new'
      msg = []
      return false
    end
    
    @user.invitations_count -= invitations_list.length    
    
    begin
      @user.transaction do
        @user.save!
        
        invitations_list.each do |invitation|
          invitation.save!
          InvitationMailer.deliver_invitation(invitation , request.host_with_port)
        end
      end
      
      #Updating current_user with the new number of invitations
      current_user.invitations_count = @user.current_invitations_count
      
      flash[:success] = "Invitation has been sent to :<br/>" + emails_list.join("<br/>")
      redirect_to :action => 'index'
      
    rescue => e
      flash.now[:alert] = e.message
      render :action => 'new'
    end    
  end
  
  def resend
    msg = []
    
    if invitation = Invitation.find(params[:id])
      if User.exists?(['email = ?', invitation.invited_email])
        msg << "The email (#{email}) already exists"
      else
        case invitation.invitation_status
          when InvitationStatus.accepted
            msg << "An invitation has been sent to the mail (#{email}), and the invitation was accepted."
        end
      end 
      
      if msg.size > 0
        flash[:alert] = msg.join("<br/>")
        redirect_to user_invitations_path(current_user)
        msg = []
        return false
      end
      
      invitation.expiry_date = Date.today + InvitationSetting.validity_period
      begin
        invitation.save!
        InvitationMailer.deliver_invitation(invitation , request.host_with_port)
        flash[:success] = "The invitation has beed sent to (#{invitation.invited_email}) successfully"
      rescue => e
        flash[:alert] = e.message
      end    
    
    else
      flash[:alert] = "Can't find the invitation"
    end    
    redirect_to user_invitations_path(current_user)
  end
  
  def accept_invitation
    invitation = Invitation.find(:first, :conditions => ["invitation_key = ? AND status = ? AND expiry_date >= ?", params[:invitation_key], false, Date.today])
    if invitation && invitation.invitation_status == InvitationStatus.waiting
      redirect_to new_user_path + "?invitation_key=#{params[:invitation_key]}"
    else
      flash[:alert] = "This invitation is not valid."
      redirect_to root_path
    end
  end
  #######
  private
  #######
  
  def is_invitations_enabled?
    if InvitationSetting.registration_type != RegistrationType.registration_with_invitation
      flash[:alert] = "Sorry, The invitation system has been disabled by the administartor"
	  redirect_to user_invitations_path(current_user)
      return false
    end
    return true
  end
end