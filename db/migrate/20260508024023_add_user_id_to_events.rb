class AddUserIdToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :user_id, :string
  end
end
