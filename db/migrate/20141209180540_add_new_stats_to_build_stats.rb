class AddNewStatsToBuildStats < ActiveRecord::Migration
  def change
    add_column :build_stats, :num_pending_bugs, :integer
    add_column :build_stats, :num_passed_wip_scenarios, :integer
  end
end
