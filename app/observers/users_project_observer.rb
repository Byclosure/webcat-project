class UsersProjectObserver < BaseObserver
  def after_create(users_project)
    notification.new_team_member(users_project)
  end

  def after_update(users_project)
    notification.update_team_member(users_project)
  end

  def after_destroy(users_project)
    #FIXME delete?
  end
end
