class CreateTestIssues < ActiveRecord::Migration
  def change
    create_table :test_issues do |t|
      t.boolean :dirty
      t.integer :type
      t.integer :subtype
      t.string :scenario_id
      t.references :build, index: true

      t.timestamps
    end
  end
end
