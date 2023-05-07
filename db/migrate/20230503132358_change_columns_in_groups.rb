class ChangeColumnsInGroups < ActiveRecord::Migration[6.0]
  def up
    # 一時的なカラムを追加
    add_column :groups, :temp_group_type, :integer
    add_column :groups, :temp_facility_environment, :integer
    add_column :groups, :temp_frequency_basis, :integer

    # 既存のカラムから一時的なカラムへデータをコピーし、データを変換
    Group.find_each do |group|
      group.update(
        temp_group_type: 0,
        temp_facility_environment: 0,
        temp_frequency_basis: 0
      )
    end

    # 既存のカラムを削除
    remove_column :groups, :group_type
    remove_column :groups, :facility_environment
    remove_column :groups, :frequency_basis

    # 一時的なカラムの名前を変更
    rename_column :groups, :temp_group_type, :group_type
    rename_column :groups, :temp_facility_environment, :facility_environment
    rename_column :groups, :temp_frequency_basis, :frequency_basis
  end

  def down
    # カラムの変更を元に戻す（必要に応じて調整）
    change_column :groups, :group_type, :string
    change_column :groups, :facility_environment, :string
    change_column :groups, :frequency_basis, :string
  end
end
