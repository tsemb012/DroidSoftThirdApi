class AddPrefectureCodeAndCityCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :prefecture_code, :integer
    add_column :users, :city_code, :integer
  end
end
