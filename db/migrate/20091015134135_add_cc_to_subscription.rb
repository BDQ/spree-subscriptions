class AddCcToSubscription < ActiveRecord::Migration
  def self.up
		add_column :subscriptions, :creditcard_id, :integer
  end

  def self.down
		remove_column :subscriptions, :creditcard_id
  end
end