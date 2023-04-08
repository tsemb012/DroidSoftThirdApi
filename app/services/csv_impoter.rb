module CsvImporter
  def import_prefecture_csv_data
    prefecture_csv_file_path = Rails.root.join('lib', 'submodule', 'location_csv', 'prefecture_csv', 'prefecture_address_jp.csv')

    Prefecture.transaction do
      Prefecture.delete_all

      CSV.foreach(prefecture_csv_file_path, headers: true) do |row|
        Prefecture.create!(row.to_h)
      end
    end
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
      end

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
