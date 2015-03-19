class AddCommitIdToBuilds < ActiveRecord::Migration
  def up
    add_column :builds, :commit_id, :string
  end

  def down
    remove_column :builds, :commit_id
  end
end
