class CreateParticipations < ActiveRecord::Migration[6.0]
  def change
    create_table :participations do |t|
      t.references :user, null: false
      t.references :group, null: false

      t.timestamps
    end
  end
end
