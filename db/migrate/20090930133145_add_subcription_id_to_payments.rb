class AddSubcriptionIdToPayments < ActiveRecord::Migration
  def self.up
		add_column :payments, :subscription_id, :integer
  end

  def self.down
		remove_column :payments, :subscription_id
  end
end