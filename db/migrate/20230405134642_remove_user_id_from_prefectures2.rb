class RemoveUserIdFromPrefectures2 < ActiveRecord::Migration[6.0]
  def change
    remove_column :prefectures, :user_id, :integer
  end
end
