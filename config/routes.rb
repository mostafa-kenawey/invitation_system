ActionController::Routing::Routes.draw do |map|
  #invitation system
  map.resources :users do |user|
    user.resources :invitations
  end
  map.resources :invitation_settings, :only => :index, :collection =>{:update_settings=>:post}
  
  map.resend_invitation '/users/:user_id/invitations/resend/:id', :controller => 'Invitations', :action=>'resend'
  map.accept_invitation '/accept_invitation/:invitation_key' , :controller => 'Invitations' , :action=>'accept_invitation'
  
  map.root :controller => 'users', :action => 'index'
  #invitation system
end
