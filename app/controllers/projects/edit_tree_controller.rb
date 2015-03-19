class Projects::EditTreeController < Projects::BaseTreeController
  before_filter :require_branch_head
  before_filter :blob
  # before_filter :authorize_push!
  
  before_filter :after_edit_path

  def show
    @last_commit = Gitlab::Git::Commit.last_for_path(@repository, @ref, @path).sha
  end

  def update
    git_params = params.dup
    git_params[:project] = @project
    git_params[:current_user] = current_user
    git_params[:ref] = @ref
    git_params[:path] = @path

    k = SshKey.where(user_id: current_user.id).first
    git_params[:key] = k

    result = repository.push!(git_params)

    if result[:status] == :success
      flash[:notice] = "Your changes have been successfully committed"

      redirect_to after_edit_path
    else
      flash[:alert] = result[:error]
      render :show
    end
  end

  private

  def blob
    @blob ||= @repository.blob_at(@commit.id, @path)
  end

  def after_edit_path
    @after_edit_path ||= project_blob_path(@project, @id)
  end
end
