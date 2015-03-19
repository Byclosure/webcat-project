class Projects::NewTreeController < Projects::BaseTreeController
  before_filter :require_branch_head

  def show
    project
    repository
  end

  def update
    file_path = File.join(@path, File.basename(params[:file_name]))
    
    git_params = params.dup
    git_params[:project] = @project
    git_params[:current_user] = current_user
    git_params[:ref] = @ref
    git_params[:path] = file_path

    k = SshKey.where(user_id: current_user.id).first
    git_params[:key] = k

    result = repository.push!(git_params, true)

    if result[:status] == :success
      flash[:notice] = "Your changes have been successfully committed"
      redirect_to project_blob_path(@project, File.join(@ref, file_path))
    else
      flash[:alert] = result[:error]
      render :show
    end
  end
end
