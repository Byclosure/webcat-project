# Module providing methods for dealing with separating a tree-ish string and a
# file path string when combined in a request parameter
module ExtractsPath
  extend ActiveSupport::Concern

  # Raised when given an invalid file path
  class InvalidPathError < StandardError; end

  included do
    if respond_to?(:before_filter)
      before_filter :assign_ref_vars
    end
  end

  

  # Assigns common instance variables for views working with Git tree-ish objects
  #
  # Assignments are:
  #
  # - @id     - A string representing the joined ref and path
  # - @ref    - A string representing the ref (e.g., the branch, tag, or commit SHA)
  # - @path   - A string representing the filesystem path
  # - @commit - A Commit representing the commit from the given ref
  #
  # If the :id parameter appears to be requesting a specific response format,
  # that will be handled as well.
  #
  # Automatically renders `not_found!` if a valid tree path could not be
  # resolved (e.g., when a user inserts an invalid path or ref).
  def assign_ref_vars
    # assign allowed options
    allowed_options = ["filter_ref", "extended_sha1"]
    @options = params.select {|key, value| allowed_options.include?(key) && !value.blank? }
    @options = HashWithIndifferentAccess.new(@options)

    @project = Project.find_with_namespace(params[:project_id]) if @project.nil?
    @id = get_id
    @ref, @path = extract_ref(@id)
    @repo = @project.repository

    if @options[:extended_sha1].blank?
      @commit = @repo.commit(@ref)
    else
      @commit = @repo.commit(@options[:extended_sha1])
    end

    raise InvalidPathError unless @commit

    @hex_path = Digest::SHA1.hexdigest(@path)
    @logs_path = logs_file_project_ref_path(@project, @ref, @path)

  rescue RuntimeError, NoMethodError, InvalidPathError
    not_found!
  end

  private

  def get_id
    id = params[:id] || params[:ref]
    id += "/" + params[:path] unless params[:path].blank?
    id
  end
end
