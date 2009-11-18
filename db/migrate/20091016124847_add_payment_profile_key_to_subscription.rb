class AddPaymentProfileKeyToSubscription < ActiveRecord::Migration
  def self.up
		add_column :subscriptions, :payment_profile_key, :string
  end

  def self.down
		remove_column :subscriptions, :payment_profile_key
  end
end