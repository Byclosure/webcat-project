class DashboardController < ApplicationController
  respond_to :html
  
  layout 'navless'

  def show
    # Fetch only 30 projects.
    # If user needs more - point to Dashboard#projects page
    @title = "#{current_user.name}'s Dashboard"

    @projects_limit = 30
    @projects = current_user.authorized_projects
    @has_authorized_projects = @projects.count > 0

    @projects_count = @projects.count
    @projects = @projects.limit(@projects_limit)

    if @projects.empty?
      @project = Project.new
    end

    @projects_charts = {}

    @projects.each { |project|
      build = Build.where(project_id: project.id, build_type: Build::TYPE_CI).last

      if build.nil?
        @projects_charts[project.id] = nil
      else
        stats = build.build_stats

        @projects_charts[project.id] = [
            {
                'label' => 'Bug',
                'value' => stats.num_failed_bugs_scenarios
            },
            {
                'label' => 'Regression Bug',
                'value' => stats.num_regression_bugs_scenarios
            },
            {
                'label' => 'Missing Automation',
                'value' => stats.num_pending_bugs
            },
            {
                'label' => 'WIP Analysis',
                'value' => stats.num_passed_wip_scenarios
            }
        ]

      end
    }

    respond_to do |format|
      format.html
    end
  end
end
