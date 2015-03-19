module BlocksHelper
  def in_expanded?(params, id)
    !params[:expanded].nil? && params[:expanded].include?(id.to_s)
  end

  def get_step_step_style(step_result)
    {
        Step::PASSED => 'step-passed',
        Step::FAILED => 'step-failed',
        Step::SKIPPED => 'step-skipped',
        Step::UNDEFINED => 'step-undefined',
        Step::PENDING => 'step-pending',
        Step::MISSING => 'step-missing'
    }[step_result]
  end

  def get_step_icon_style(step_result)
    {
        Step::PASSED => 'text-success',
        Step::FAILED => 'text-danger',
        Step::SKIPPED => 'text-muted',
        Step::UNDEFINED => 'text-warning',
        Step::PENDING => 'text-warning',
        Step::MISSING => 'text-warning'
    }[step_result]
  end

  def get_step_tooltip(step_result)
    {
        Step::PASSED => 'passed',
        Step::FAILED => 'failed',
        Step::SKIPPED => 'skipped',
        Step::UNDEFINED => 'pending',
        Step::PENDING => 'pending',
        Step::MISSING => 'pending'
    }[step_result]
  end

  def move_to_page_param(params, page_num)
    new_params = params.clone

    new_params.delete(:expanded)

    new_params.merge({:page => page_num})
  end

  ### Example
  ### option = {:filter_type => ScenarioCategories::FEATURE}
  def add_or_remove_param(params, option, multiple = true)
    new_params = params.clone

    option.each_pair { |key, value|
      value = value.to_s
      if(new_params[key].nil?)
        new_params.merge!({key => [value]})
      elsif(new_params[key].include? value)
        new_params[key] = Array.new(new_params[key])
        new_params[key].delete(value)
      else
        if(multiple)
          new_params[key] = Array.new(new_params[key])
        else
          new_params[key] = []
        end

        new_params[key] << value
      end
    }

    new_params.delete(:page)
    new_params.delete(:expanded)
    new_params
  end

  def has_param?(params, option)
    option.each_pair { |key, value|
      value = value.to_s

      if(params[key].nil?)
        return false
      elsif(params[key].include? value)
        return true
      else
        return false
      end
    }
  end
end