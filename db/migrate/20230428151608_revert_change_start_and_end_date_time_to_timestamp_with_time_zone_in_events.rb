class RevertChangeStartAndEndDateTimeToTimestampWithTimeZoneInEvents < ActiveRecord::Migration[6.0]
  def change
    change_column :events, :start_date_time, :datetime, using: 'start_date_time::timestamp without time zone'
    change_column :events, :end_date_time, :datetime, using: 'end_date_time::timestamp without time zone'
  end
end
