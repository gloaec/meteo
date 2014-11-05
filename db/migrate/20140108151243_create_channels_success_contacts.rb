class CreateChannelsSuccessContacts < ActiveRecord::Migration
  def change
    create_table :channels_success_contacts do |t|
      t.references :channel # index: true
      t.references :user    # index: true

      t.timestamps
    end
    add_index :channels_success_contacts, [:channel_id, :user_id], :unique => true
  end
end
