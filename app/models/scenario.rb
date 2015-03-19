class Scenario

  attr_accessor :id, :named_id, :name, :feature, :steps, :uri, :tags, :types, :build

  def initialize(params={})
    @named_id, @name, @steps, @feature, @uri = params[:named_id], params[:name], params[:steps], params[:feature], params[:uri]
    @id, @keyword, @build = params[:id], params[:keyword], params[:build]

    @tags = params[:tags]

    cats = ScenarioCategories.categorize(@tags, passed?)
    @types = cats[:types]
    @wip = cats[:wip]

    @skipped = @tags.include? ScenarioCategories::SKIPPED
  end

  def previous_runs
    previous = []

    Build.where('project_id = ? AND created_at < ?', @build.project.id, @build.created_at).order(:created_at).find_each { |build|
      scenario = build.find_scenario_by_named_id(@named_id)
      if !scenario.nil?
        previous << scenario
      end
    }

    previous
  end

  def is_outline?
    @keyword == 'Scenario Outline'
  end

  def failed?
    !@steps.find(&:failed?).nil?
  end

  def passed?
    (@steps.select{ |s| !s.passed? }).empty?
  end

  def pending?
    !(@steps.select{ |s| s.pending? }).empty?
  end

  def wip?
    @wip
  end

  def skipped?
    @skipped
  end
end