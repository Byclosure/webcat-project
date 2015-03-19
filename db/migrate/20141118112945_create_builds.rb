class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.text :json

      t.timestamps
    end
  end
end
