class AddCategoryToTestIssues < ActiveRecord::Migration
  def change
    add_column :test_issues, :category, :integer
  end
end
