class Repository
  include Gitlab::ShellAdapter

  attr_accessor :raw_repository, :path_with_namespace

  def initialize(path_with_namespace, default_branch = nil)
    # debugger

    @path_with_namespace = path_with_namespace
    @raw_repository = Gitlab::Git::Repository.new(path_to_repo) if path_with_namespace
  rescue Gitlab::Git::Repository::NoRepository
    nil
  end

  def path_to_repo
    @path_to_repo ||= Repository::path_to_repo_with_path(path_with_namespace)
  end

  def exists?
    raw_repository
  end

  def empty?
    raw_repository.empty?
  end

  def pull!(key)
    raw_repository.pull!(key)
    raw_repository
  end

  def clone!(git_url, key)
    @raw_repository = Gitlab::Git::Repository.clone!(git_url, path_to_repo, key)
  end

  def push!(params = {}, new_file=false)
    unless branch_names.include?(params[:ref])
      return error("You can only create files if you are on top of a branch")
    end

    unless new_file
      blob = blob_at_branch(params[:ref], params[:path])

      unless blob
        return error("You can only edit text files")
      end
    end

    created_successfully = raw_repository.commit!(params)

    if created_successfully
      success
    else
      error("Your changes could not be committed, because the connection with the remote repository timed out.")
    end
  end

  def delete!(params = {})
    unless branch_names.include?(params[:ref])
      return error("You can only create files if you are on top of a branch")
    end

    blob = blob_at_branch(params[:ref], params[:path])

    unless blob
      return error("File doesn't exist in the repository")
    end
    
    deleted_successfully = raw_repository.delete!(params)

    if deleted_successfully
      success
    else
      error("Your changes could not be committed, because the connection with the remote repository timed out.")
    end
  end

  def commit(id = nil)
    return nil unless raw_repository
    raw_commit = Gitlab::Git::Commit.find(raw_repository, id)
    
    Commit.new(raw_commit) if raw_commit
  end

  def commits(ref, path = nil, limit = nil, offset = nil)
    commits = Gitlab::Git::Commit.where(
      repo: raw_repository,
      ref: ref,
      path: path,
      limit: limit,
      offset: offset,
    )
    commits = Commit.decorate(commits) if commits.present?
    commits
  end

  def commits_between(from, to)
    commits = Gitlab::Git::Commit.between(raw_repository, from, to)
    commits = Commit.decorate(commits) if commits.present?
    commits
  end

  def find_branch(name)
    branches.find { |branch| branch.name == name }
  end

  def find_tag(name)
    tags.find { |tag| tag.name == name }
  end

  def recent_branches(limit = 20)
    branches.sort do |a, b|
      commit(b.target).committed_date <=> commit(a.target).committed_date
    end[0..limit]
  end

  def add_branch(branch_name, ref)
    Rails.cache.delete(cache_key(:branch_names))

    gitlab_shell.add_branch(path_with_namespace, branch_name, ref)
  end

  def add_tag(tag_name, ref)
    Rails.cache.delete(cache_key(:tag_names))

    gitlab_shell.add_tag(path_with_namespace, tag_name, ref)
  end

  def rm_branch(branch_name)
    Rails.cache.delete(cache_key(:branch_names))

    gitlab_shell.rm_branch(path_with_namespace, branch_name)
  end

  def rm_tag(tag_name)
    Rails.cache.delete(cache_key(:tag_names))

    gitlab_shell.rm_tag(path_with_namespace, tag_name)
  end

  def round_commit_count
    if commit_count > 10000
      '10000+'
    elsif commit_count > 5000
      '5000+'
    elsif commit_count > 1000
      '1000+'
    else
      commit_count
    end
  end

  def branch_names
    raw_repository.branch_names
    # Rails.cache.fetch(cache_key(:branch_names)) do
    #   raw_repository.branch_names
    # end
  end

  def tag_names
    raw_repository.tag_names
    # Rails.cache.fetch(cache_key(:tag_names)) do
    #   raw_repository.tag_names
    # end
  end

  def commit_count
    Rails.cache.fetch(cache_key(:commit_count)) do
      begin
        raw_repository.raw.commit_count
      rescue
        0
      end
    end
  end

  # Return repo size in megabytes
  # Cached in redis
  def size
    Rails.cache.fetch(cache_key(:size)) do
      raw_repository.size
    end
  end

  def expire_cache
    Rails.cache.delete(cache_key(:size))
    Rails.cache.delete(cache_key(:branch_names))
    Rails.cache.delete(cache_key(:tag_names))
    Rails.cache.delete(cache_key(:commit_count))
    Rails.cache.delete(cache_key(:graph_log))
    Rails.cache.delete(cache_key(:readme))
    Rails.cache.delete(cache_key(:contribution_guide))
  end

  def graph_log
    Rails.cache.fetch(cache_key(:graph_log)) do
      stats = Gitlab::Git::GitStats.new(raw, root_ref)
      stats.parsed_log
    end
  end

  def cache_key(type)
    "#{type}:#{path_with_namespace}"
  end

  def method_missing(m, *args, &block)
    raw_repository.send(m, *args, &block)
  end

  def respond_to?(method)
    return true if raw_repository.respond_to?(method)

    super
  end

  def blob_at(sha, path)
    begin
      Blob.new(sha: sha, path: path, repository: self)
    rescue
      nil
    end
  end

  def readme
    Rails.cache.fetch(cache_key(:readme)) do
      tree(:head).readme
    end
  end

  def contribution_guide
    Rails.cache.fetch(cache_key(:contribution_guide)) do
      tree(:head).contribution_guide
    end
  end

  def head_commit
    commit(self.root_ref)
  end

  def tree(sha = :head, path = nil)
    if sha == :head
      sha = head_commit.sha
    end

    Tree.new(self, sha, path)
  end

  def blob_at_branch(branch_name, path)
    last_commit = commit(branch_name)

    if last_commit
      blob_at(last_commit.sha, path)
    else
      nil
    end
  end

  # Returns url for submodule
  #
  # Ex.
  #   @repository.submodule_url_for('master', 'rack')
  #   # => git@localhost:rack.git
  #
  def submodule_url_for(ref, path)
    if submodules(ref).any?
      submodule = submodules(ref)[path]

      if submodule
        submodule['url']
      end
    end
  end

  def last_commit_for_path(sha, path)
    commits(sha, path, 1).last
  end

  def self.path_to_repo_with_path(path)
    File.join(Gitlab.config.gitlab_shell.repos_path, path + ".git")
  end

  ###### Webcat
  def self.clean_local_copy!(path_to_repo)
    FileUtils.rm_rf(Repository::path_to_repo_with_path(path_to_repo))
  end

  private
  def error(message)
      {
        error: message,
        status: :error
      }
  end

  def success
    {
      error: '',
      status: :success
    }
  end
end
