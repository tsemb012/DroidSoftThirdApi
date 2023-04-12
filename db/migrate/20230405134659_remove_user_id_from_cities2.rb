class RemoveUserIdFromCities2 < ActiveRecord::Migration[6.0]
  def change
    remove_column :cities, :user_id, :integer
  end
end
