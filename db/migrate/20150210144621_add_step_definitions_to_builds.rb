class AddStepDefinitionsToBuilds < ActiveRecord::Migration
  def up
    add_column :builds, :step_definitions, :text
  end

  def down
    remove_column :builds, :step_definitions
  end
end
