class BuildStats < ActiveRecord::Base
  belongs_to :build

  attr_accessible :num_features, :num_scenario, :num_passed_features, :num_passed_scenarios
  attr_accessible :num_feature_bugs, :num_software_bugs, :num_software_miss, :num_automation_bugs
  attr_accessible :num_automation_miss, :num_analysis_bugs, :num_analysis_miss
  attr_accessible :num_total_scenarios_with_software, :automation_goal_progress, :num_failed_bugs
  attr_accessible :num_passed_wip_scenarios, :num_pending_bugs
  attr_accessible :num_pending_bugs_scenarios, :num_failed_bugs_scenarios
  attr_accessible :num_regression_bugs_scenarios


end
