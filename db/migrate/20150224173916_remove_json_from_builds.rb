class RemoveJsonFromBuilds < ActiveRecord::Migration
  def up
    remove_column :builds, :json
  end

  def down
    add_column :builds, :json, :text, :limit => 4294967295
  end
end
