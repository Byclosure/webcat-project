class AddStepDefinitionMatchesToBuilds < ActiveRecord::Migration
  def up
    add_column :builds, :step_definition_matches, :text
  end

  def down
    remove_column :builds, :step_definition_matches
  end
end
