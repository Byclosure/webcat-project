class AddGoalsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :passed_goal, :decimal
    add_column :projects, :software_goal, :decimal
    add_column :projects, :automation_goal, :decimal
  end
end
