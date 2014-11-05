class CreateFtps < ActiveRecord::Migration
  def change
    create_table :ftps do |t|
      t.string :host
      t.integer :port
      t.string :user,               :null => false, :default => ""
      t.column :password_digest, :binary, :limit => 10.megabyte
      t.boolean :passive
      t.references :channel

      t.timestamps
    end
  end
end
