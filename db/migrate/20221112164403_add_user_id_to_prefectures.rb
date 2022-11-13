class AddUserIdToPrefectures < ActiveRecord::Migration[6.0]
  def change
    add_column :prefectures, :user_id, :integer
  end
end
