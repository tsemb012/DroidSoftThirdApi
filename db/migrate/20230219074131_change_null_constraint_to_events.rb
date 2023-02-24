class ChangeNullConstraintToEvents < ActiveRecord::Migration[6.0]
  def change
    change_column_null :events, :place_id, true
  end
end
