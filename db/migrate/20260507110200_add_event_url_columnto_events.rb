class AddEventUrlColumntoEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :event_url, :string
  end
end
