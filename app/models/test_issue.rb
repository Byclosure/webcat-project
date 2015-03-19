class TestIssue < ActiveRecord::Base
  belongs_to :build

  attr_accessible :dirty, :category, :subtype, :scenario_id, :description, :step_order

  def scenario
    @scenario ||= build.find_scenario_by_id(scenario_id)
  end

  def wip?
    scenario.wip?
  end

  def problem_step
    # if category == ScenarioCategories::REGRESSIONBUG || category == ScenarioCategories::FAILEDBUG
    #   scenario.steps.find(&:failed?)
    # elsif category == ScenarioCategories::PENDINGBUG
    #   scenario.steps.find(&:pending?)
    # else
    #   nil
    # end
    scenario.steps.find { |s| s.order == step_order }
  end

end
