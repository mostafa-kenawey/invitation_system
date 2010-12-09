class AddInvitationsCountAndExpirationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invitations_count, :integer, :default=>0
    add_column :users, :invitations_expiration, :datetime
  end

  def self.down
    remove_column :users, :invitations_count
    remove_column :users, :invitations_expiration
  end
end
