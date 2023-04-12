class AddPrefectureCodeAndLgCodeToCities < ActiveRecord::Migration[6.0]
  def change
    add_column :cities, :prefecture_code, :string
    add_column :cities, :lg_code, :string
  end
end
