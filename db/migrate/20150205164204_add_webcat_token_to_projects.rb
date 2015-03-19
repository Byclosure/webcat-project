require 'securerandom'

class AddWebcatTokenToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :webcat_token, :string

    Project.transaction do 
      Project.all.each do |p|
        p.webcat_token = SecureRandom.hex
        p.save!
      end
    end
  end

  def down
    remove_column :projects, :webcat_token
  end
end