class ChangeAgeToBirthdayInUsers < ActiveRecord::Migration[6.0]
  def up
    # カラム名を変更せず、新たにbirthdayカラムを追加
    add_column :users, :birthday, :date

    # すでにあるデータを変換
    User.reset_column_information
    User.find_each do |user|
      # ここでは誕生日を計算してデータを変換していますが、
      # 実際の変換方法は年齢から誕生日に変換する方法に合わせて適宜変更してください
      user.birthday = Date.today - (user.age || 10).years
      user.save!
    end

    # ageカラムを削除
    remove_column :users, :age
  end

  def down
    add_column :users, :age, :integer

    User.reset_column_information
    User.find_each do |user|
      # 誕生日から年齢に変換
      user.age = ((Date.today - user.birthday) / 365).to_i
      user.save!
    end

    remove_column :users, :birthday
  end
end
