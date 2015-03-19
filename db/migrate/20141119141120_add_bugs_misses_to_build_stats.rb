class AddBugsMissesToBuildStats < ActiveRecord::Migration
  def change
    add_column :build_stats, :num_feature_bugs, :integer
    add_column :build_stats, :num_software_bugs, :integer
    add_column :build_stats, :num_software_miss, :integer
    add_column :build_stats, :num_automation_bugs, :integer
    add_column :build_stats, :num_automation_miss, :integer
    add_column :build_stats, :num_analysis_bugs, :integer
    add_column :build_stats, :num_analysis_miss, :integer
  end
end
