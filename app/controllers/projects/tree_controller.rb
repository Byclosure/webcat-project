# Controller for viewing a repository's file structure
class Projects::TreeController < ApplicationController
  layout 'projects'

  def show
    @project = project
    if(params[:id] == "[no_ref]")
      render "empty"
      return
    end
    
    allowed_options = ["filter_ref", "extended_sha1"]
    options = params.select {|key, value| allowed_options.include?(key) && !value.blank? }
    options = HashWithIndifferentAccess.new(options)

    
    @id = params[:id]
    @ref, @path = extract_ref(@id)
    @repo = @project.repository
    @commit = if options[:extended_sha1].blank?
      @repo.commit(@ref)
    else
      @repo.commit(options[:extended_sha1])
    end

    @tree ||= @repo.tree(@commit.id, @path)

    return not_found! if @tree.entries.empty?

    respond_to do |format|
      format.html
    end
  end
end
