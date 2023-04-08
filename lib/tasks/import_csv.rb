require 'csv_importer'

namespace :import_csv do
  include CsvImporter

  desc "Import prefecture and city CSV data"
  task import: :environment do
    import_prefecture_csv_data
    import_city_csv_data
  end
end

