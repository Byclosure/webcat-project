class Step

  PASSED = 0
  FAILED = 1
  SKIPPED = 2
  UNDEFINED =3
  PENDING = 4
  MISSING = 5

  attr_accessor :result, :name, :keyword, :scenario_named_id, :order, :rows, :error, :location

  def initialize(params={})
    @result, @name, @keyword, @shot = params[:result], params[:name], params[:keyword], params[:shot]
    @scenario_named_id, @order, @build = params[:scenario_named_id], params[:order], params[:build]
    @rows, @error, @location = params[:rows], params[:error], params[:location]
  end

  def shot
    ss_list = StepScreenshot.where build_id: @build.id, scenario_id: @scenario_named_id
    #, location: @location, step_order: @order

    base_ss_index = 0

    for step_index in 0..scenario.steps.length-1 do
      current_step = scenario.steps[step_index]

      for current_ss_index in base_ss_index..ss_list.length-1 do
        current_ss = ss_list[current_ss_index]

        if current_ss.location == current_step.location
          if @order == current_step.order # my step
            return 'data:image/png;base64,'+current_ss.shot
          else
            base_ss_index = current_ss_index + 1
            break
          end
        end
      end
      
      if current_step.failed?
        break
      end
    end

    screenshot_holder_step = scenario.steps.select { |s| s.has_screenshots? }.first

    if !screenshot_holder_step.nil? && !screenshot_holder_step.all_shots.nil?
      screenshot = screenshot_holder_step.all_shots[@order]

      if !screenshot.nil?
        return 'data:'+screenshot['mime_type']+';base64,'+screenshot['data']
      end
    end

    nil
  end

  def scenario
    @build.find_scenario_by_named_id(@scenario_named_id)
  end

  def has_rows?
    !@rows.nil?
  end

  def all_shots
    @shot
  end

  def has_screenshots?
    !@shot.nil?
  end

  def failed?
    @result == FAILED
  end

  def skipped?
    @result == SKIPPED
  end

  def passed?
    @result == PASSED
  end

  def pending?
    [UNDEFINED, MISSING, PENDING].include? @result
  end

  def self.map_result(string)
    {'passed' => PASSED,
     'failed' => FAILED,
     'skipped' => SKIPPED,
     'undefined' => UNDEFINED,
     'pending' => PENDING,
     'missing' => MISSING}[string]
  end
end