class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :age
      t.string :sexuality
      #t.references :activity_area, null: false, foreign_key: true
      #t.references :preference, null: false, foreign_key: true
      #t.references :setting, null: false, foreign_key: true

      t.timestamps
    end
  end
end
