class ChangePlaceIdNullConstraintToEvents < ActiveRecord::Migration[6.0]
  def change
    def up
      change_column_null :events, :place_id, null: true
    end
    def down
      change_column_null :events, :place_id, null: false
    end
  end
end
