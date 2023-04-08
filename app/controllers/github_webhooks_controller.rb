class GithubWebhooksController < ActionController::API

  include GithubWebhook::Processor

  # Handle push event
  def github_push(payload)
    repo_url = payload['repository']['html_url']

    if repo_url == 'https://github.com/tsemb012/LocationCsv'
      load_csv
    else
      Rails.logger.info("Unhandled repository: #{repo_url}")
    end
    head :ok
  end

  # Handle create event
  def github_create(payload)
    # handle create webhook
  end

  private

  def webhook_secret(payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end

  private

  def load_csv
    load_prefecture_csv
    load_city_csv
  end

  def load_prefecture_csv
    if request.headers['X-GitHub-Event'] == 'push'
      #valitationをかける必要がある。　→　勝手にデータベースを操作されちゃうかもしれない。
      import_prefecture_csv_data
    end
    head :ok
  end

  def load_city_csv
    if request.headers['X-GitHub-Event'] == 'push'
      #valitationをかける必要がある。　→　勝手にデータベースを操作されちゃうかもしれない。
      import_city_csv_data
    end
    head :ok
  end


  def import_prefecture_csv_data #TODO ここのコードを書き換えるように。
    prefecture_csv_file_path = Rails.root.join('lib', 'submodule', 'location_csv', 'prefecture_csv', 'prefecture_address_jp.csv')

    Prefecture.transaction do
      Prefecture.delete_all

      CSV.foreach(prefecture_csv_file_path, headers: true) do |row|
        Prefecture.create!(row.to_h)
      end
    end # TODO　一旦、このままで進めてみる。　
  end

  def import_city_csv_data
    city_name_csv_file_path = Rails.root.join('lib', 'submodule', 'location_csv', 'city_name_csv', 'city_name.csv')
    city_latlng_csv_file_path = Rails.root.join('lib', 'submodule', 'location_csv', 'city_latlng_csv', 'city_latlng.csv')


    City.transaction do
      City.delete_all

      city_name_data = {}
      CSV.foreach(city_name_csv_file_path, headers: false) do |row|
        city_code = row[0].to_i
        city_name_data[city_code] = {
          city_name: row[1],
          city_kana: row[2],
          city_spell: row[3],
          prefecture_code: row[4].to_i,
        }
      end #companionObeject的なもので、わかりやすいようにConstを置いておく。

      CSV.foreach(city_latlng_csv_file_path, headers: true) do |row|
        city_code = row[2].to_i
        merged_table_data = {
          city_code: city_code,
          city_name: city_name_data[city_code][:city_name],
          city_kana: city_name_data[city_code][:city_kana],
          city_spell: city_name_data[city_code][:city_spell],
          prefecture_code: city_name_data[city_code][:prefecture_code],
          lat: row[5],
          lng: row[6],
          lg_code: row[9],
        }
        City.create!(merged_table_data)
      end
    end
  end
end
