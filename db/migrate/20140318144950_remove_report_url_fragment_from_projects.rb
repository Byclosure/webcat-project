class RemoveReportUrlFragmentFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :ci_report_url_fragment
  end
end
