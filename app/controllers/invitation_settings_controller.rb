class InvitationSettingsController < InvitationApplicationController
  def index
	@invitation_settings = InvitationSetting.find :all
  end
  
  def update_settings
    InvitationSetting.transaction do 
	  params[:invitation_settings].each do |key, value|
	    invitation_setting = InvitationSetting.find_by_key(key)
	    invitation_setting.update_attribute(:value, value) if invitation_setting
	  end
	end
	
	flash[:success] = t("invitation_system.setting.updated")
	redirect_to invitation_settings_path
  rescue => e
    flash[:alert] = e.message
    redirect_to invitation_settings_path
  end
end