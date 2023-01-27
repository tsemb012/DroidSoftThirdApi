class MapsController < ApplicationController

  TEXT_QUERY = "textquery"
  FIELDS = 'name,place_id,geometry,types,photos,formatted_address,plus_code'

  def initialize
    @conn = Faraday.new(url: 'https://maps.googleapis.com/maps/api/place/') do |builder|
      builder.request :url_encoded
      builder.response :logger
      builder.adapter Faraday.default_adapter
      #builder.use_ssl = true
    end
  end

  def search_query
    response = @conn.get 'findplacefromtext/json',
                         inputtype: TEXT_QUERY,
                         fields: FIELDS,
                         input: params[:input].as_json,
                         language: params[:language].as_json,
                         locationbias: params[:south_lat] + ',' + params[:west_lng] + '|' + params[:north_lat] + ',' + params[:west_lng],
                         key: ENV['GOOGLE_API_KEY'],
                         limit: 10
                         # 最大20件であれば制限する必要はないかも。

    response_code = response.status
    response_headers = response.headers
    response_body_json = response.body
    data = JSON.parse(response_body_json)
    candidates = data["candidates"]
    json1 = JSON.generate(candidates)
    json2 = JSON.pretty_generate(candidates)
    render json: candidates # 把握できなくなる　→　ので、Selializer　→　GitLabのレポジトリ　→　コードを見にいく　→　
  end

  def search_nearby
    response = @conn.get 'nearbysearch/json',
                         location: params[:location].as_json,
                         radius: params[:radius].as_json,
                         type: params[:type].as_json,
                         keyword: params[:keyword].as_json,

                         #pagetoken: params[:pagetoken].as_json,
                         language: 'ja',
                         key: ENV['GOOGLE_API_KEY']
    render json: response.body
  end

  def search_text
    response = @conn.get 'textsearch/json',
                         query: params[:query].as_json,
                         location: params[:location].as_json,
                         radius: params[:radius].as_json,
                         type: params[:type].as_json,
                         region: params[:region].as_json,
                         language: 'ja',
                         key: ENV['GOOGLE_API_KEY']
    render json: response.body
  end
end

=begin
  def searchAA




    @search_term = params[:looking_for]
    @movie_results = Map.search(@search_term)
    #@map = Map.find(params[:input, :input_type, :fields,  ])
    #どこにコードを記述すれば良いのか？
    # 文字列検索 → POIは使えないけど、正直他のAPIでも大丈夫？　→ Yahooとか
      # Mapデータベースではなく、APIにリクエストを投げる。
      # input Stringテキスト
      # input_type textquery or phonenumber
      # パラメーターの渡し方ってどうだっけ？　リクエストの投げ方を確認する必要がある。
      # fields返ってくる値を指定できる。　Basicだと基本料金のまま
      # https://developers.google.com/maps/documentation/places/web-service/search-find-place
      # language 日本語にする
      # locationbias 範囲選択ができる。詳細については公式ドキュメントから
    # net/httpを使うとURLを作るのがすげーめんどくさそう。
      # Httpartyを使うと多分簡単にできるはず、難しいようだったら他のHttpClientを立てる。
  end
    end
=end

