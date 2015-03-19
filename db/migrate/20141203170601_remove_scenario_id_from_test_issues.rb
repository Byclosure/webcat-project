class RemoveScenarioIdFromTestIssues < ActiveRecord::Migration
  def change
    remove_column :test_issues, :scenario_id, :string
  end
end
