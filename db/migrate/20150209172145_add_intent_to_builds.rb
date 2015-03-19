class AddIntentToBuilds < ActiveRecord::Migration
  def up
    add_column :builds, :intent, :string
  end

  def down
    remove_column :builds, :intent
  end
end
