class CreateChannelsFtps < ActiveRecord::Migration
  def change
    create_table :channels_ftps do |t|
      t.references :channel, index: true
      t.references :ftp, index: true
      t.string :success_path
    end
  end
end
