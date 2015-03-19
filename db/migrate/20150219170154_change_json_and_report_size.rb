class ChangeJsonAndReportSize < ActiveRecord::Migration
  def up
    change_column :builds, :json, :text, :limit => 4294967295
    change_column :builds, :report, :text, :limit => 4294967295
  end

  def down
    change_column :builds, :json, :text
    change_column :builds, :report, :text, :limit => 16.megabytes-1
  end
end
