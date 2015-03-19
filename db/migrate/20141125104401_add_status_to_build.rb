class AddStatusToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :successful, :boolean
  end
end
