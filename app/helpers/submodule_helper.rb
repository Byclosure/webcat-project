module SubmoduleHelper
  include Gitlab::ShellAdapter

  # links to files listing for submodule if submodule is a project on this server
  def submodule_links(submodule_item)
    url = @repository.submodule_url_for(@ref, submodule_item.path)

    return url, nil unless url =~ /([^\/:]+\/[^\/]+\.git)\Z/

    project = $1
    project.chomp!('.git')

    if self_url?(url, project)
      return project_path(project), project_tree_path(project, submodule_item.id)
    elsif github_dot_com_url?(url)
      standard_links('github.com', project, submodule_item.id)
    elsif gitlab_dot_com_url?(url)
      standard_links('gitlab.com', project, submodule_item.id)
    else
      return url, nil
    end
  end

  protected

  def github_dot_com_url?(url)
    url =~ /github\.com[\/:][^\/]+\/[^\/]+\Z/
  end

  def gitlab_dot_com_url?(url)
    url =~ /gitlab\.com[\/:][^\/]+\/[^\/]+\Z/
  end

  def self_url?(url, project)
    return true if url == [ Gitlab.config.gitlab.url, '/', project, '.git' ].join('')
    url == gitlab_shell.url_to_repo(project)
  end

  def standard_links(host, project, commit)
    base = [ 'https://', host, '/', project ].join('')
    return base, [ base, '/tree/', commit ].join('')
  end
end
