class AddForeignKeyParticipations < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :participations, :users
    add_foreign_key :participations, :groups
  end
end
