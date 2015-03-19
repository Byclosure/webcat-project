module DashboardHelper
  def filter_path(entity, options={})
    exist_opts = {
      state: params[:state],
      scope: params[:scope],
      project_id: params[:project_id],
    }

    options = exist_opts.merge(options)

    path = request.path
    path << "?#{options.to_param}"
    path
  end

  def entities_per_project(project, entity)
    #FIXME remove
    
    0
  end

  def projects_dashboard_filter_path(options={})
    exist_opts = {
      sort: params[:sort],
      scope: params[:scope],
      group: params[:group],
    }

    options = exist_opts.merge(options)

    path = request.path
    path << "?#{options.to_param}"
    path
  end
end
