class Projects::ResultsController < Projects::ApplicationController
  helper_method :get_icon_class_info, :get_scenario

  def index
    build_id = params[:build]
    build_type = params[:build_type]

    if build_id.nil? || build_type.nil?
      @build = Build.where(project_id: project.id, build_type: Build::TYPE_CI).last
    else
      @build = Build.find_by project_id: project.id, id: build_id.to_d, build_type: build_type
    end

    if @build.nil?
      @blocks_by_feature = {}
      return
    end

    filter_status = params[:filter_status]

    if(!(filter_status.nil? || filter_status.empty?))
      scenarios = []

      if filter_status.include? ScenarioStates::PASSED.to_s
        scenarios.concat @build.scenarios.select { |s| s.passed? }
      end

      if filter_status.include? ScenarioStates::FAILED.to_s
        scenarios.concat @build.scenarios.select { |s| s.failed? }
      end

      if filter_status.include? ScenarioStates::PENDING.to_s
        scenarios.concat @build.scenarios.select { |s| s.pending? }
      end

    else
      scenarios = @build.scenarios
    end

    filter_wip = params[:filter_wip]

    if(!(filter_wip.nil? || filter_wip.empty?))
      scenarios = scenarios.select { |s| s.wip?.to_s == filter_wip.first }
    end

    #### Pagination ####
    pagination = paginate(params[:page], params[:expanded], scenarios) { |b| b }

    if(pagination[:redirect])
      redirect_to project_results_path(params.merge(pagination[:addons]))
    else
      @page_num = pagination[:page_num]
      @num_pages = pagination[:num_pages]
      @blocks_by_feature = pagination[:blocks_by_feature]
    end

    @feature_root = @project.valid_repo? ? @build.head + '/' + @project.test_path + '/' : nil

  end

  def get_scenario(block)
    block
  end

  def get_icon_class_info(scenario)
    if(scenario.pending?)
      text_class = 'scenario-pending'
      bg_class = 'scenario-pending-bg'
    elsif(scenario.passed?)
      text_class = 'scenario-passed'
      bg_class = 'scenario-passed-bg'
    else
      text_class = 'scenario-failed'
      bg_class = 'scenario-failed-bg'
    end

    {
        :text_class => text_class,
        :bg_class => bg_class,
        :icon_class => 'icon-list-ul',
        :title => 'Scenario'
    }
  end

end
