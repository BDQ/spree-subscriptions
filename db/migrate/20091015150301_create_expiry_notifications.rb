class CreateExpiryNotifications < ActiveRecord::Migration
  def self.up
    create_table :expiry_notifications do |t|
			t.integer :subscription_id
			t.integer	:interval
      t.timestamps
    end
  end

  def self.down
    drop_table :expiry_notifications
  end
end
