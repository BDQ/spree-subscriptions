class AddFieldsToVariant < ActiveRecord::Migration
  def self.up
		add_column :variants, :subscribable, :boolean, :default => false		
  end

  def self.down
		remove_column :variants, :subscribable
  end
end