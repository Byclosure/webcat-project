class CreateUserLeads < ActiveRecord::Migration
  def change
    create_table :user_leads do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
