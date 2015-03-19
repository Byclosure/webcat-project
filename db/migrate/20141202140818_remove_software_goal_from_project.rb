class RemoveSoftwareGoalFromProject < ActiveRecord::Migration
  def change
    remove_column :projects, :software_goal, :decimal
  end
end
