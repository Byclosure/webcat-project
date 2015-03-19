class AddTypeToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :build_type, :integer
  end
end
