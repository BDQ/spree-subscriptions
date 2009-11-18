class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.date :start_date
      t.date :end_date
			t.integer :duration
			t.string :interval
			t.string :state
			t.references :user
			t.references :variant
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
