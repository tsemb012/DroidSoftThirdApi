rails generate model ArticleUser article:references user:referencesclass CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :image_url
      t.string :name
      t.text :introduction
      t.string :type
      t.string :prefecture
      t.string :city
      t.string :facility_environment
      t.string :string
      t.string :frequency_basis
      t.integer :frequency_times
      t.integer :max_age
      t.integer :min_age
      t.integer :max_number
      t.integer :min_number
      t.boolean :is_same_sexuality

      t.timestamps
    end
  end
end
