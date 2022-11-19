class RenameSexualityColumnToUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :sexuality, :gender
  end
end
