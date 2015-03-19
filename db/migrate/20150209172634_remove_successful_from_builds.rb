class RemoveSuccessfulFromBuilds < ActiveRecord::Migration
  def up
    remove_column :builds, :successful 
  end

  def down
    add_column :builds, :successful, :boolean
  end
end
