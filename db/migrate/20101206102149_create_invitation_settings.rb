class CreateInvitationSettings < ActiveRecord::Migration
  def self.up
    create_table :invitation_settings do |t|
      t.string   :key
      t.string   :value
      t.string   :description
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invitation_settings
  end
end
