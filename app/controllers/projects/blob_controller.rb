# Controller for viewing a file's blame
class Projects::BlobController < Projects::ApplicationController
  # include ExtractsPath

  class InvalidPathError < StandardError; end

  # Authorize
  # before_filter :authorize_read_project!
  # before_filter :authorize_code_access!
  # before_filter :require_non_empty_project
  
  before_filter :blob

  def show
  end

  def destroy
    git_params = params.dup
    git_params[:project] = @project
    git_params[:current_user] = current_user
    git_params[:ref] = @ref
    git_params[:path] = @path

    k = SshKey.where(user_id: current_user.id).first
    git_params[:key] = k

    result = repository.delete!(git_params)

    if result[:status] == :success
      flash[:notice] = "Your changes have been successfully committed"
      redirect_to project_tree_path(@project, @ref)
    else
      flash[:alert] = result[:error]
      render :show
    end
  end

  private

  def blob
    if !assign_ref_vars
      project.pull_repository!  #last attempt to get the commit

      if !assign_ref_vars #still no luck; just quit
        return not_found!
      end

    end

    @is_editable = @ref == @project.repository.root_ref

    @blob ||= @repo.blob_at(@commit.id, @path)

    return not_found! unless @blob

    @blob
  end

  def assign_ref_vars
    # assign allowed options
    allowed_options = ["filter_ref", "extended_sha1"]
    @options = params.select {|key, value| allowed_options.include?(key) && !value.blank? }
    @options = HashWithIndifferentAccess.new(@options)

    @project = Project.find_with_namespace(params[:project_id])
    @id = get_id
    @ref, @path = extract_ref(@id)
    @repo = @project.repository

    if @options[:extended_sha1].blank?
      @commit = @repo.commit(@ref)
    else
      @commit = @repo.commit(@options[:extended_sha1])
    end

    return false unless @commit

    @hex_path = Digest::SHA1.hexdigest(@path)
    @logs_path = logs_file_project_ref_path(@project, @ref, @path)

    rescue RuntimeError, NoMethodError
      return false

    return true
  end

  def get_id
    id = params[:id] || params[:ref]
    id += "/" + params[:path] unless params[:path].blank?
    id
  end
end
