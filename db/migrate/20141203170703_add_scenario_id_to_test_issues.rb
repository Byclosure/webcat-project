class AddScenarioIdToTestIssues < ActiveRecord::Migration
  def change
    add_column :test_issues, :scenario_id, :integer
  end
end
