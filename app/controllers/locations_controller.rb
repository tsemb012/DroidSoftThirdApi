class LocationsController < ActionController::API
  protect_from_forgery with: :null_session # webhookに使うのでCSRF対策を無効化する

  def load_prefecture_csv
    if request.headers['X-GitHub-Event'] == 'push'

      import_prefecture_csv_data

=begin
      # 追加、変更、削除されたファイルのリストを取得します。
      added_files = params[:head_commit][:added]
      modified_files = params[:head_commit][:modified]
      removed_files = params[:head_commit][:removed]
      # CSVファイルが更新されたかどうかをチェックします。
      if updated_prefecture_csv_file?(added_files) || updated_prefecture_csv_file?(modified_files) || updated_prefecture_csv_file?(removed_files)
      end
=end
    end
    head :ok
  end

  def load_city_csv
    if request.headers['X-GitHub-Event'] == 'push'

      import_city_csv_data
=begin
      # 追加、変更、削除されたファイルのリストを取得します。
      added_files = params[:head_commit][:added]
      modified_files = params[:head_commit][:modified]
      removed_files = params[:head_commit][:removed]
      # CSVファイルが更新されたかどうかをチェックします。
      if updated_city_csv_file?(added_files) || updated_city_csv_file?(modified_files) || updated_city_csv_file?(removed_files)
        # Rakeタスクを実行します。
        system("bundle exec rake your_namespace:your_task")
      end
=end
    end
    head :ok
  end

  private


  def import_prefecture_csv_data #TODO ここのコードを書き換えるように。
    prefecture_csv_file_path = Rails.root.join('lib', 'submodule', 'location_csv', 'prefecture_csv', 'prefecture_address_jp.csv')

    Prefecture.transaction do
      Prefecture.delete_all

      CSV.foreach(prefecture_csv_file_path, headers: true) do |row|
        Prefecture.create!(row.to_h)
      end
    end
  end

  def import_city_csv_data
    city_latlng_csv_file_path = Rails.root.join('lib', 'submodule', 'location_csv', 'city_latlng_csv', 'city_latlng.csv')
    city_name_csv_file_path = Rails.root.join('lib', 'submodule', 'location_csv', 'city_name_csv', 'city_name.csv')


    City.transaction do
      City.delete_all

      CSV.foreach(csv_file_path, headers: true) do |row|
        City.create!(row.to_h)
      end
    end
  end

  # 更新されたCSVファイルが存在するかどうかを判断するメソッド
  def updated_prefecture_csv_file?(file_list)
    # 検索したいCSVファイルの名前またはパスを指定します。
    target_csv_file = 'path/to/your/csv_file.csv'

    file_list.any? { |file| file == target_csv_file }
  end

  def updated_city_csv_file?(file_list)
    # 検索したいCSVファイルの名前またはパスを指定します。
    target_csv_file = 'path/to/your/csv_file.csv'

    file_list.any? { |file| file == target_csv_file }
  end
end
