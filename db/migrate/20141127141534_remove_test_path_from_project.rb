class RemoveTestPathFromProject < ActiveRecord::Migration
  def change
    remove_column :projects, :test_name, :string
  end
end
