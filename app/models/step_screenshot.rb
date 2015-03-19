class StepScreenshot < ActiveRecord::Base
  belongs_to :build

  attr_accessible :scenario_id, :step_order, :ss_order, :shot, :location
end
