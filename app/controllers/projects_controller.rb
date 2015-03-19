require 'tempfile'

class ProjectsController < ApplicationController
  skip_before_filter :authenticate_user!, :only => :run
  # Authorize
  # before_filter :authorize_read_project!, except: [:index, :new, :create]
  before_filter :require_non_empty_project, only: [:blob, :tree, :graph]

  layout 'navless', only: [:new, :create, :fork]
  before_filter :set_title, only: [:new, :create]

  def new
    @project = Project.new
  end

  def edit
    project
    repository
  end

  def create
    @project = new_project(params)
    begin
      ActiveRecord::Base.transaction do
        if @project.save!
          unless @project.group
            @project.users_projects.create!(project_access: UsersProject::MASTER, user: current_user)
          end
        end
      end
    rescue
      @project.errors.add(:base, "Can't save project. Please try again later")
    end

    respond_to do |format|
      flash[:notice] = 'Project was successfully created.' if @project.saved?
      format.html do
        if @project.saved?
          redirect_to project_summary_index_path(@project)
        else
          render 'new'
        end
      end
    end
  end

  def ci
    project
    repository

    @valid_ci_settings = false
    begin
      @builds, @last_build_url = load_builds
      @valid_ci_settings = true
    rescue JenkinsApi::Exceptions::Unauthorized
      flash[:alert] = "Wrong Jenkins credentials. Please check your Continuous Integration username/password configurations"
    rescue JenkinsApi::Exceptions::NotFound
      flash[:alert] = "Could not find job with given name. Please check your Continuous Integration configurations"
    end
  end

  def ci_build
    project
    repository

    begin
      @project.ci_run_job(current_user.webcat_token)
      flash[:notice] = "Build started. Wait a moment to check the result" 
    rescue
      flash[:alert] = "There was an error running the job. Please try again later"
    end

    redirect_to project_summary_index_path(@project)
  end

  def ci_build_single
    project
    repository

    begin
      @project.ci_run_single_job(current_user.webcat_token, params[:sha], params[:test_id])
      flash[:notice] = "Build started. Wait a moment to check the result"
    rescue
      flash[:alert] = "There was an error running the job. Please try again later"
    end

    redirect_to project_blob_path(@project, :id => project.repository.root_ref + '/' + params[:test_id])
  end

  def ci_update
    project
    repository

    if params[:project]
      ci_schedule_value = params[:project][:ci_schedule]
      begin
        @project.ci_schedule = ci_schedule_value
        flash[:notice] = "Changes saved successfully"
      rescue
        flash[:alert] = "Could not save the changes. Please try again later"
      end
    else
      flash[:alert] = "Could not save the changes. Please try again later"
    end

    redirect_to ci_project_path(@project)
  end

  def transfer
    project = project()
    begin
      if project.repo_exists?
        project.pull_repository!
      else
        project.clone_repository!
      end
    rescue => e
      @project.errors.add(:base, "Could not update project's files. Please try again later")
    end

    respond_to do |format|
      if @project.errors.empty?
        flash[:notice] = "Project files were successfully updated."
        format.html { redirect_to project_tree_path(project, project.repository.root_ref) }
      else
        flash[:alert] = "Could not update project's files. Please try again later"
        format.html { redirect_to project_tree_path(project, "[no_ref]") }
      end
    end
  end

  def update
    project
    repository

    params[:project].delete(:namespace_id)
      
    new_branch = params[:project].delete(:default_branch)

    if project.repository.exists? && new_branch && new_branch != project.default_branch
      project.change_head(new_branch)
    end

    begin
      status = project.update_attributes(params[:project], as: :default)
    rescue
      flash[:alert] = 'Could not save settings'
      status = false
    end

    respond_to do |format|
      if status
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to project_summary_index_path(@project) }
        format.js
      else
        format.html { render 'edit' }
        format.js
      end
    end
  end

  def show
    id = params[:project_id] || params[:id]

    @project = project

    #FIXME
    if @project.nil?
      return      
    end

    @repository ||= begin
      @project.repository
    rescue Grit::NoSuchPathError
      nil
    end

    limit = (params[:limit] || 20).to_i

    @valid_ci_settings = false
    begin
      @builds, @last_build_url = load_builds
      @valid_ci_settings = true
    rescue JenkinsApi::Exceptions::Unauthorized
      @builds = []
      flash[:alert] = "Wrong Jenkins credentials. Please check your Continuous Integration username/password configurations"
    rescue JenkinsApi::Exceptions::NotFound
      @builds = []
      flash[:alert] = "Could not find job with given name. Please check your Continuous Integration configurations"
    end

    respond_to do |format|
      format.html do
        if current_user
          @last_push = current_user.recent_push(@project.id)
        end
        render :show, layout: user_layout
      end
    end
  end

  def destroy
    project
    repository
    
    project.clean_repository!
    project.team.truncate
    project.destroy
    
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Project successfully removed" }
    end
  end

  def autocomplete_sources
    project
    repository
    @suggestions = {
      emojis: Emoji.names,
      members: @project.team.members.sort_by(&:username).map { |user| { username: user.username, name: user.name } }
    }

    respond_to do |format|
      format.json { render :json => @suggestions }
    end
  end

  def runner_configs

    # debugger

    file_content = "WEBCAT_PROJECT=#{project.to_param}\nWEBCAT_PROJECT_TOKEN=#{project.webcat_token}\nWEBCAT_HOST=#{params[:host]}"
    
    send_data file_content, filename: "webcat.properties", content_type: "plain/text"
  end

  def run
    
    environment = params[:environment]
    project_name = environment["WEBCAT_PROJECT"]

    @project = Project.all.select { |o| o.to_param == project_name }.first
    
    if(@project.nil?)
      render json: params, status: 404
      return
    elsif @project.webcat_token != environment['WEBCAT_PROJECT_TOKEN']
      render json: params, status: 403
      return
    end


    intent = WebcatIntent.new.from_json(environment['WEBCAT_INTENT'])
    @build = Build.new(
        number: environment['BUILD_NUMBER'].to_d,
        build_type: intent.size != 1 ? Build::TYPE_CI : Build::TYPE_INDIVIDUAL,
        intent: environment['WEBCAT_INTENT'],
        commit_id: environment['GIT_COMMIT'],
        step_definitions: params[:stepDefinitions].to_s,
        step_definition_matches: params[:stepDefinitionMatches].to_s
    )

    report = params[:features]

    @build.project = @project
    @project.builds << @build

    processed_report = processStepScreenshots(report, @build)
    @build.report = processed_report.to_json

    failing_steps = @build.steps.select { |s| s.failed? }

    regression_steps = []
    bugs_steps = []

    failing_steps.each { |step|
      previous_runs = step.scenario.previous_runs

      if previous_runs.find(&:passed?).nil? #no previous run where this scenario passed
        bugs_steps << step
      else
        regression_steps << step
      end
    }

    create_issue_by_step(bugs_steps, ScenarioCategories::FAILEDBUG)
    create_issue_by_step(regression_steps, ScenarioCategories::REGRESSIONBUG)

    pending_steps = @build.steps.select { |s| s.pending? }
    create_issue_by_step(pending_steps, ScenarioCategories::PENDINGBUG)

    passed_wip_scenarios = @build.scenarios.select { |s| s.wip? && s.passed? }
    passed_wip_scenarios.each { |s|

      issue = TestIssue.new(
          dirty: false,
          category: ScenarioCategories::WIPANALYSIS,
          subtype: ScenarioCategories::BUG,
          description: '',
          scenario_id: s.id
      )
      issue.build = @build
      @build.test_issues << issue

      issue.save
    }

    #number of features
    num_features = @build.features.count

    #number of scenarios
    num_scenarios = @build.scenarios.count

    #number of pending scenarios
    num_pending_scenarios = @build.scenarios.select(&:pending?).count

    #number of passing_scenarios
    num_passed_scenarios = @build.scenarios.select { |s| s.passed? }.count

    #number of passing features
    num_passed_features = @build.features.select { |f|
      @build.scenarios_by_feature(f).select { |s| !s.passed? }.count == 0
    }.count

    #automation goal

    software_inplace = @build.scenarios.select {|s| !s.types.any? {|t|
      t[:type] == ScenarioCategories::SOFTWARE &&
          t[:subtype] == ScenarioCategories::MISSING
    } }

    automation_goal_progress = software_inplace.select {|s| !s.types.any? {|t|
      t[:type] == ScenarioCategories::AUTOMATION &&
          t[:subtype] == ScenarioCategories::MISSING
    } }

    build_stats = BuildStats.new(
        num_scenario: num_scenarios,
        num_features: num_features,
        num_passed_features: num_passed_features,
        num_passed_scenarios: num_passed_scenarios,
        num_failed_bugs: failing_steps.count,
        num_pending_bugs: pending_steps.count,
        num_failed_bugs_scenarios: bugs_steps.count,
        num_regression_bugs_scenarios: regression_steps.count,
        num_pending_bugs_scenarios: num_pending_scenarios,
        num_passed_wip_scenarios: passed_wip_scenarios.count,
        num_total_scenarios_with_software: software_inplace.count,
        automation_goal_progress: automation_goal_progress.count
    )

    
    build_stats.build = @build
    @build.build_stats = build_stats
    build_stats.save

    @build.save!

    render json: {'build' => @build.number}
  end

  private

  def set_title
    @title = 'New Project'
  end

  def user_layout
    current_user ? "projects" : "public_projects"
  end

  def new_project(params)
    # get namespace id
    namespace_id = params.delete(:namespace_id)

    project = Project.new(params[:project])
    project.path = project.name && project.name.parameterize

    if namespace_id
      # Find matching namespace and check if it allowed
      # for current user if namespace_id passed.
      if allowed_namespace?(current_user, namespace_id)
        project.namespace_id = namespace_id
      else
        project.errors.add(:namespace, "is not valid")
        return project
      end
    else
      # Set current user namespace if namespace_id is nil
      project.namespace_id = current_user.namespace_id
    end

    project.creator = current_user
    project
  end

  def allowed_namespace?(user, namespace_id)
    namespace = Namespace.find_by(id: namespace_id)
    current_user.can?(:manage_namespace, namespace)
  end

  def load_builds
    builds = @project.cibuilds

    unless builds.empty?
      last_build_url = builds.first.url
    else
      last_build_url = ""
    end

    [builds, last_build_url]
  end

  def processStepScreenshots(report, build)
    report.each_index do |feature_index|
      feature = report[feature_index]

      feature['elements'].each_index do |scenario_index|
        scenario = feature['elements'][scenario_index]

        steps = scenario['steps']
        
        steps.each_with_index do |step, step_index|
          screenshots = step['screenshots']

          if(!screenshots.nil? && screenshots.size > 0)
            screenshot = StepScreenshot.new(
                scenario_id: scenario['id'],
                step_order: step['line'],
                ss_order: 0,
                location: step['match']['location'],
                shot: screenshots.first
              )

            build.step_screenshots << screenshot
            screenshot.build = build
            screenshot.save!

            report[feature_index]['elements'][scenario_index]['steps'][step_index].delete('screenshots')
          end
        end
      end
    end

    report
  end

  def find_issues
    scenarios_with_type = []

    @build.scenarios.each { |s|
      problems = s.types.select { |t|
        yield t
      }

      if(!problems.empty?)
        scenarios_with_type << {:scenario => s, :type => problems.first}
      end
    }

    scenarios_with_type
  end

  def create_issue_by_step(steps, category)
    steps.each { |s|
      scenario = @build.find_scenario_by_named_id(s.scenario_named_id)

      issue = TestIssue.new(
          dirty: false,
          category: category,
          subtype: ScenarioCategories::BUG,
          description: '',
          scenario_id: scenario.id,
          step_order: s.order
      )
      issue.build = @build
      @build.test_issues << issue

      issue.save
    }
  end
end
