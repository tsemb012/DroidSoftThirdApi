class AddUserIdToCities < ActiveRecord::Migration[6.0]
  def change
    add_column :cities, :user_id, :integer
  end
end
