class AddDetailsToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :report, :text
    add_reference :builds, :project, index: true
  end
end
