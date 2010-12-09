class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
       t.integer  :user_id
       t.string   :inviter_name, :null=> false
       t.string   :body
       t.string   :invited_email
       t.integer  :invited_id
       t.string   :invitation_key
       t.boolean  :status , :default=>false
       t.date     :expiry_date
    end
  end

  def self.down
    drop_table :invitations
  end
end
