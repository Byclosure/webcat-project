class CreateBuildStats < ActiveRecord::Migration
  def change
    create_table :build_stats do |t|
      t.integer :num_features
      t.integer :num_scenario
      t.integer :num_wip
      t.integer :num_passed_features
      t.integer :num_passed_scenarios
      t.references :build, index: true

      t.timestamps
    end
  end
end
