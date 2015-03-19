class AddStepOrderToTestIssues < ActiveRecord::Migration
  def change
    add_column :test_issues, :step_order, :integer
  end
end
