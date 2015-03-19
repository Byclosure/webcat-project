class AddRegressionBugsToBuildStats < ActiveRecord::Migration
  def change
    add_column :build_stats, :num_regression_bugs_scenarios, :integer
  end
end
