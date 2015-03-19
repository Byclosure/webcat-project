class CreateStepScreenshots < ActiveRecord::Migration
  def change
    create_table :step_screenshots do |t|
      t.string :scenario_id
      t.integer :step_order
      t.integer :ss_order
      t.text :shot, :limit => 16.megabytes- 1
      t.references :build, index: true

      t.timestamps
    end
  end
end
