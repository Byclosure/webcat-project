class RemoveTypeFromTestIssues < ActiveRecord::Migration
  def change
    remove_column :test_issues, :type, :integer
  end
end
