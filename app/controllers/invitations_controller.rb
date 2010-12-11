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
            msg = t("invitation_system.invitation.messages.expired")
          else
            msg = t("invitation_system.invitation.messages.more_users")
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
    msg << t("invitation_system.invitation.messages.emails_empty") if emails.empty?
    msg << t("invitation_system.invitation.messages.maximum_limit") if emails.length > @user.current_invitations_count
    msg << t("invitation_system.invitation.messages.sender_name") if params[:inviter_name].blank?
    msg << t("invitation_system.invitation.messages.invitation_message") if params[:body].blank?
    
    emails.each do |key, email|
      if !(email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
        msg << t("invitation_system.invitation.messages.not_valid_email", :email=>email)
      elsif User.exists?(['email = ?', email])
        msg << t("invitation_system.invitation.messages.email_exists", :email=>email)
      elsif user_invitation = Invitation.find_by_invited_email(email)
        case user_invitation.invitation_status
          when InvitationStatus.waiting
            msg << t("invitation_system.invitation.messages.waiting_for_reply", :email=>email)
          when InvitationStatus.expired
            msg << t("invitation_system.invitation.messages.invitation_expired", :email=>email)
          when InvitationStatus.accepted
            msg << t("invitation_system.invitation.messages.invitation_accepted", :email=>email)
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
        msg << t("invitation_system.invitation.messages.not_valid_email", :email=>email)
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
	  
      flash[:success] = t("invitation_system.invitation.messages.invitation_sent", :emails=>emails_list.join("<br/>"))
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
        msg << t("invitation_system.invitation.messages.email_exists", :email=>email)
      else
        case invitation.invitation_status
          when InvitationStatus.accepted
            msg << t("invitation_system.invitation.messages.invitation_accepted", :email=>email)
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
        flash[:success] = t("invitation_system.invitation.messages.invitation_sent", :emails=>invitation.invited_email)
      rescue => e
        flash[:alert] = e.message
      end    
    
    else
      flash[:alert] = t("invitation_system.invitation.messages.invitation_not_found")
    end    
    redirect_to user_invitations_path(current_user)
  end
  
  def accept_invitation
    invitation = Invitation.find(:first, :conditions => ["invitation_key = ? AND status = ? AND expiry_date >= ?", params[:invitation_key], false, Date.today])
    if invitation && invitation.invitation_status == InvitationStatus.waiting
      redirect_to new_user_path + "?invitation_key=#{params[:invitation_key]}"
    else
      flash[:alert] = t("invitation_system.invitation.messages.invitation_not_valid")
      redirect_to root_path
    end
  end
  #######
  private
  #######
  
  def is_invitations_enabled?
    if InvitationSetting.registration_type != RegistrationType.registration_with_invitation
      flash[:alert] = t("invitation_system.invitation.messages.invitation_system_id_disabled")
	  redirect_to user_invitations_path(current_user)
      return false
    end
    return true
  end
end