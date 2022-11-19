class CreatePrefectures < ActiveRecord::Migration[6.0]
  def change
    create_table :prefectures do |t|
      t.integer :prefecture_code
      t.string :name
      t.string :spell

      t.timestamps
    end
  end
end
