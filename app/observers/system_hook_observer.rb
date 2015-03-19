class SystemHookObserver < BaseObserver
  observe :user, :project, :users_project

  def after_create(model)
  end

  def after_destroy(model)
  end

  private

  def system_hook_service
    SystemHooksService.new
  end
end
