class AddScenarioStatusesToBuildStats < ActiveRecord::Migration
  def change
    add_column :build_stats, :num_failed_bugs_scenarios, :integer
    add_column :build_stats, :num_pending_bugs_scenarios, :integer
  end
end
