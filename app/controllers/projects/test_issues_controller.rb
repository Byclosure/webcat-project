class Projects::TestIssuesController < Projects::ApplicationController

  helper_method :get_icon_class_info, :get_scenario

  def index
    build_id = params[:build]

    if(build_id.nil?)
      @build = Build.where(project_id: project.id, build_type: Build::TYPE_CI).last
    else
      @build = Build.find_by project_id: project.id, id: build_id.to_d, build_type: Build::TYPE_CI
    end


    if(@build.nil?)
      @blocks_by_feature = {}
      return
    end

    @all_issues = @build.test_issues


    filter_type = params[:filter_type]

    if(!(filter_type.nil? || filter_type.empty?))
      @issues = []
      filter_type.each { |f|
        @issues.concat @all_issues.select { |i| i.category == f.to_i }
      }
    else
      @issues = @all_issues
    end

    filter_subtype = params[:filter_subtype]

    if(!(filter_subtype.nil? || filter_subtype.empty?))
      @issues = @issues.select { |i| i.subtype == filter_subtype.first.to_i  }
    end

    #### Pagination ####
    pagination = paginate(params[:page], params[:expanded], @issues) { |b| b.scenario }

    if(pagination[:redirect])
      redirect_to project_test_issues_path(params.merge(pagination[:addons]))
      return
    else
      @page_num = pagination[:page_num]
      @num_pages = pagination[:num_pages]
      @blocks_by_feature = pagination[:blocks_by_feature]
    end

    @feature_root = @project.valid_repo? ? @build.head + '/' + @project.test_path + '/' : nil
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
                ScenarioCategories::PENDINGBUG => {
                    :text_class => 'missing-automation',
                    :bg_class => 'missing-automation-bg',
                    :icon_class => 'icon-bug',
                    :title => 'Missing Automation'},
                ScenarioCategories::WIPANALYSIS => {
                    :text_class => 'wip-analysis',
                    :bg_class => 'wip-analysis-bg',
                    :icon_class => 'icon-exclamation-sign',
                    :title => 'WIP Analysis'}
            }
    }

    t[issue.subtype][issue.category]
  end

  def get_scenario(block)
    block.scenario
  end
end
