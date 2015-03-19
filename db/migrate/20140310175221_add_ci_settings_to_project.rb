class AddCiSettingsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :ci_url, :string
    add_column :projects, :ci_username, :string
    add_column :projects, :ci_password, :string
    add_column :projects, :ci_job_name, :string
    add_column :projects, :ci_report_url_fragment, :string
  end
end
