require 'securerandom'

class AddWebcatTokenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :webcat_token, :string

    User.transaction do 
      User.all.each do |u|
        u.webcat_token = SecureRandom.hex
        u.save!
      end
    end
  end

  def down
    remove_column :users, :webcat_token
  end
end
