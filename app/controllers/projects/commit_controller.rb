# Controller for a specific Commit
#
# Not to be confused with CommitsController, plural.
class Projects::CommitController < Projects::ApplicationController
  # Authorize
  before_filter :require_non_empty_project
  before_filter :commit

  def show
    return git_not_found! unless @commit

    @branches = project.repository.branch_names_contains(commit.id)

    begin
      @suppress_diff = true if commit.diff_suppress? && !params[:force_show_diff]
      @force_suppress_diff = commit.diff_force_suppress?
    rescue Grit::Git::GitTimeout
      @suppress_diff = true
      @status = :huge_commit
    end

    @noteable = @commit
    @comments_allowed = @reply_allowed = true
    @comments_target  = {
      noteable_type: 'Commit',
      commit_id: @commit.id
    }

    respond_to do |format|
      format.html do
        if @status == :huge_commit
          render "huge_commit" and return
        end
      end

      format.diff  { render text: @commit.to_diff }
      format.patch { render text: @commit.to_patch }
    end
  end

  def commit
    @commit ||= project.repository.commit(params[:id])
  end
end
