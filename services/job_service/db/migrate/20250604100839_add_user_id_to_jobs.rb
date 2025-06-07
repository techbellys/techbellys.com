class AddUserIdToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :user_id, :integer
  end
end
