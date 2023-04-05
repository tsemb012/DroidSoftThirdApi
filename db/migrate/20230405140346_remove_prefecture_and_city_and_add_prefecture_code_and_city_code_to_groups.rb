class RemovePrefectureAndCityAndAddPrefectureCodeAndCityCodeToGroups < ActiveRecord::Migration[6.0]
  def change
    # prefectureとcityカラムを削除
    remove_column :groups, :prefecture, :string
    remove_column :groups, :city, :string

    # prefecture_codeとcity_codeカラムを追加
    add_column :groups, :prefecture_code, :integer
    add_column :groups, :city_code, :integer
  end
end
