class MapsController < ApplicationController

  #TODO リファクタリング。ChatGPTだとエラー
  TEXT_QUERY = "textquery"
  INDIVIDUAL_FIELDS = 'name,place_id,geometry,types,photos,formatted_address,plus_code'
  DETAIL_FIELD = 'name,type,place_id,formatted_address,geometry,icon_background_color,url,photo,address_component,plus_code'

  def initialize
    @conn = Faraday.new(url: 'https://maps.googleapis.com/maps/api/place/') do |builder|
      builder.request :url_encoded
      builder.response :logger
      builder.adapter Faraday.default_adapter
      #builder.use_ssl = true
    end
  end

  def search_individual # ピンポイント検索
    response = @conn.get 'findplacefromtext/json',
                         inputtype: TEXT_QUERY,
                         fields: INDIVIDUAL_FIELDS,
                         input: params[:input],
                         language: params[:language],
                         locationbias: 'rectangle:' + params[:south_lat] + ',' + params[:west_lng] + '|' + params[:north_lat] + ',' + params[:west_lng],
                         key: ENV['GOOGLE_API_KEY']
    response_body_json = response.body
    data = JSON.parse(response_body_json)
    candidates = data["candidates"]
    render json: candidates
  end

  def search_by_text
    response = @conn.get 'textsearch/json',
                         query: params[:query],
                         location: params[:center_lat] + ',' + params[:center_lng],
                         radius: params[:radius],
                         type: params[:type],
                         region: params[:region],
                         language: params[:language],
                         key: ENV['GOOGLE_API_KEY']
    response_body_json = response.body
    data = JSON.parse(response_body_json)
    candidates = data["results"]
    render json: candidates
  end

  def search_nearby
    response = @conn.get 'nearbysearch/json',
                         location: params[:center_lat] + "," + params[:center_lng],
                         radius: params[:radius],
                         type: params[:type],
                         language: params[:language],
                         key: ENV['GOOGLE_API_KEY']
    response_body_json = response.body
    data = JSON.parse(response_body_json)
    candidates = data["results"]
    render json: candidates
  end

  def fetch_place_detail
    response = @conn.get 'details/json',
                         place_id: params[:place_id],
                         fields: DETAIL_FIELD,
                         language: params[:language],
                         key: ENV['GOOGLE_API_KEY']
    response_body_json = response.body
    data = JSON.parse(response_body_json)
    candidates = data["result"]
    render json: candidates
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

