class CreateChannelsUsers < ActiveRecord::Migration
  def change
    create_table :channels_users do |t|
      t.references :channel#, index: true
      t.references :user#, index: true
      t.string     :role
      t.string     :success
      t.string     :error

      t.timestamps
    end
    add_index :channels_users, [:channel_id, :user_id], :unique => true
  end
end
