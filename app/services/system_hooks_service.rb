class SystemHooksService

  private

  def build_event_data(model, event)
    data = {
      event_name: build_event_name(model, event),
      created_at: model.created_at
    }

    case model
    when Project
      owner = model.owner

      data.merge!({
        name: model.name,
        path: model.path,
        path_with_namespace: model.path_with_namespace,
        project_id: model.id,
        owner_name: owner.name,
        owner_email: owner.respond_to?(:email) ?  owner.email : nil
      })
    when User
      data.merge!({
        name: model.name,
        email: model.email,
        user_id: model.id
      })
    when UsersProject
      data.merge!({
        project_name: model.project.name,
        project_path: model.project.path,
        project_id: model.project_id,
        user_name: model.user.name,
        user_email: model.user.email,
        project_access: model.human_access
      })
    end
  end

  def build_event_name(model, event)
    case model
    when UsersProject
      return "user_add_to_team"      if event == :create
      return "user_remove_from_team" if event == :destroy
    else
      "#{model.class.name.downcase}_#{event.to_s}"
    end
  end
end
