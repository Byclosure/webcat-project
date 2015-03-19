class AddNumFailedBugsToBuildStats < ActiveRecord::Migration
  def change
    add_column :build_stats, :num_failed_bugs, :integer
  end
end
