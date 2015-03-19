class AddDescriptionToTestIssue < ActiveRecord::Migration
  def change
    add_column :test_issues, :description, :string
  end
end
