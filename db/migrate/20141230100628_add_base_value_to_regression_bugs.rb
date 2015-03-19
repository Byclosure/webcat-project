class AddBaseValueToRegressionBugs < ActiveRecord::Migration
  def up
    BuildStats.update_all(num_regression_bugs_scenarios: 0)
  end

  def down

  end
end
