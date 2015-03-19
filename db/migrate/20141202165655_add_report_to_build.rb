class AddReportToBuild < ActiveRecord::Migration
  def change
    add_column :builds, :report, :text, :limit => 16.megabytes- 1
  end
end
