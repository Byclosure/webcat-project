class ProjectObserver < BaseObserver
  def after_create(project)
    project.update_column(:last_activity_at, project.created_at)

    return true
  end

  def after_update(project)
    project.rename_repo if project.path_changed?
  end

  def before_destroy(project)
    project.repository.expire_cache unless project.empty_repo?
  end

  def after_destroy(project)
    log_info("Project \"#{project.name}\" was removed")
  end
end
