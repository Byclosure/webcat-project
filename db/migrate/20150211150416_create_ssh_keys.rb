class CreateSshKeys < ActiveRecord::Migration
  def up
    create_table :ssh_keys do |t|
      t.integer :user_id
      t.text :public_key
      t.text :private_key
    end

    SshKey.transaction do
      User.all.each do |u|
        SshKey.create_keys!(u)
      end
    end
  end

  def down
    drop_table :ssh_keys
  end
end
