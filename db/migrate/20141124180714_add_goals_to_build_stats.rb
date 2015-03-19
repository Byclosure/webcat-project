class AddGoalsToBuildStats < ActiveRecord::Migration
  def change
    add_column :build_stats, :num_total_scenarios_with_software, :integer
    add_column :build_stats, :automation_goal_progress, :integer
  end
end
