class RemoveReportFromBuild < ActiveRecord::Migration
  def change
    remove_column :builds, :report, :text
  end
end
