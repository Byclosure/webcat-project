class AddTestPathToProject < ActiveRecord::Migration
  def change
    add_column :projects, :test_name, :string
  end
end
