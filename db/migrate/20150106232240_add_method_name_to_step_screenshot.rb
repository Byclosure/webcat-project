class AddMethodNameToStepScreenshot < ActiveRecord::Migration
  def change
    add_column :step_screenshots, :location, :string
  end
end
