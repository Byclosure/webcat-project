class AddRealTestPathToProject < ActiveRecord::Migration
  def change
    add_column :projects, :test_path, :string
  end
end
