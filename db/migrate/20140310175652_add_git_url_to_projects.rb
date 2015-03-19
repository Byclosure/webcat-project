class AddGitUrlToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :git_url, :string
  end
end
