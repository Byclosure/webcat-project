class Projects::SummaryController < Projects::ApplicationController

  helper_method :get_icon_class_info

  def index
    @ci_builds = Build.where(project_id: project.id, build_type: Build::TYPE_CI).last(10)
    @individual_builds = Build.where(project_id: project.id, build_type: Build::TYPE_INDIVIDUAL).last(10)

    if(@ci_builds.empty?)
      @has_builds = false
      return
    else
      @has_builds = true
    end

    @build = @ci_builds.last
    @build_stats = @build.build_stats

    @issues = @build.test_issues.last(10)

    if(!project.passed_goal.nil?)
      if(@build_stats.num_features > 0)
        @goal_passed_current = @build_stats.num_passed_features.fdiv(@build_stats.num_features)*100
        @goal_passed_current = @goal_passed_current.truncate
      else
        @goal_passed_current = 0
      end
      @goal_passed_target = project.passed_goal
    end

    if(!project.automation_goal.nil?)
      if(@build_stats.num_scenario > 0)
        @goal_automation_current = (@build_stats.num_scenario-@build_stats.num_pending_bugs_scenarios).fdiv(@build_stats.num_scenario)*100
        @goal_automation_current = @goal_automation_current.truncate
      else
        @goal_automation_current = 0
      end
      @goal_automation_target = project.automation_goal
    end

    progress_bugs_data = []
    progress_regression_bugs_data = []
    progress_pending_bugs_data = []
    progress_passed_wip_scenarios = []

    progress_global_failed_data = []
    progress_global_passed_data = []

    @progress_label = []

    @progress_bugs_max = 0

    @ci_builds.last(5).each_with_index {|b, index|
      stats = b.build_stats

      #### BUGS ####

      progress_bugs_data << {
          'x' => index,
          'y' => stats.num_failed_bugs_scenarios
      }

      progress_regression_bugs_data << {
          'x' => index,
          'y' => stats.num_regression_bugs_scenarios
      }

      progress_pending_bugs_data << {
          'x' => index,
          'y' => stats.num_pending_bugs
      }

      #### WIP ####

      progress_passed_wip_scenarios << {
          'x' => index,
          'y' => stats.num_passed_wip_scenarios
      }

      #### GLOBAL ####

      progress_global_failed_data << {
          'x' => b.pretty_name,
          'y' => (stats.num_scenario - stats.num_passed_scenarios)
      }

      progress_global_passed_data << {
          'x' => b.pretty_name,
          'y' => stats.num_passed_scenarios
      }

      @progress_label << b.pretty_name
    }

    @progress_data = [
        {
            'key' => 'Bug',
            'values' => progress_bugs_data
        },
        {
            'key' => 'Regression Bug',
            'values' => progress_regression_bugs_data
        },
        {
            'key' => 'Missing Automation',
            'values' => progress_pending_bugs_data
        },
        {
            'key' => 'WIP Analysis',
            'values' => progress_passed_wip_scenarios
        }
    ]

    @breakdown_data = [
        {
            'label' => 'Bug',
            'value' => progress_bugs_data.last['y']
        },
        {
            'label' => 'Regression Bug',
            'value' => progress_regression_bugs_data.last['y']
        },
        {
            'label' => 'Missing Automation',
            'value' => progress_pending_bugs_data.last['y']
        },
        {
            'label' => 'WIP Analysis',
            'value' => progress_passed_wip_scenarios.last['y']
        }
    ]

    @progress_global_data = [
        {
            'key' => 'Failed',
            'values' => progress_global_failed_data,
        }, {
            'key' => 'Passed',
            'values' => progress_global_passed_data,
        }
    ]

    @current_global_data = [
        {
            'label' => 'Failed',
            'value' => (@build_stats.num_failed_bugs_scenarios + @build_stats.num_regression_bugs_scenarios),
        },{
            'label' => 'Pending',
            'value' => @build_stats.num_pending_bugs_scenarios,
        }, {
            'label' => 'Passed',
            'value' => progress_global_passed_data.last['y'],
        }
    ]

    wip_scenarios = @build.scenarios.select{|i| i.wip? }.count

    @state_data = [
        {
          'label' => 'Not in Progress',
          'value' => (@build_stats.num_scenario-wip_scenarios)
        }, {
          'label' => 'In Progress',
          'value' => wip_scenarios
        }
    ]
  end

  def get_icon_class_info(issue)
    t = {
        ScenarioCategories::BUG =>
            {
                ScenarioCategories::FAILEDBUG => {
                    :text_class => 'failed-bug',
                    :bg_class => 'failed-bug-bg',
                    :icon_class => 'icon-bug',
                    :title => 'Bug'},
                ScenarioCategories::REGRESSIONBUG => {
                    :text_class => 'regression-bug',
                    :bg_class => 'regression-bug-bg',
                    :icon_class => 'icon-bug',
                    :title => 'Regression Bug'},
                ScenarioCategories::WIPANALYSIS => {
                    :text_class => 'wip-analysis',
                    :bg_class => 'wip-analysis-bg',
                    :icon_class => 'icon-exclamation-sign',
                    :title => 'WIP Analysis'},
                ScenarioCategories::PENDINGBUG => {
                    :text_class => 'missing-automation',
                    :bg_class => 'missing-automation-bg',
                    :icon_class => 'icon-bug',
                    :title => 'Missing Automation'}
            }
    }

    t[issue.subtype][issue.category]
  end
end