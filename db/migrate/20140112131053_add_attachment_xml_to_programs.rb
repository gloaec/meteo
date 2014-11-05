class AddAttachmentXmlToPrograms < ActiveRecord::Migration
  def self.up
    change_table :programs do |t|
      t.attachment :xml
    end
  end

  def self.down
    drop_attached_file :programs, :xml
  end
end
