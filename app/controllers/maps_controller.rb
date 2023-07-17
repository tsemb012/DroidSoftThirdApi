class MapsController < ApplicationController

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
                         query: CGI::escape(params[:input]),
                         location: params[:center_lat] + ',' + params[:center_lng],
                         radius: params[:radius],
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

  YOLP_LOCAL_SEARCH_ENDPOINT = 'https://map.yahooapis.jp/search/local/V1/localSearch'.freeze

  def yolp_text_search
    extra_params = { sort: 'match'}
    yolp_search(extra_params)
  end

  def yolp_auto_complete
    extra_params = { sort: 'dist'}
    yolp_search(extra_params)
  end

  def yolp_category_search
    extra_params = { gc: params[:category] }
    yolp_search(extra_params)
  end


  # uid検索　詳細情報を取得する。
  def yolp_detail_search
    place = {
      appid: ENV['YAHOO_APP_ID'],
      id: params[:uid],
      device: 'mobile',
      detail: 'full',
      results: 1,
      output: 'json'
    }

    response = @conn.get(YOLP_LOCAL_SEARCH_ENDPOINT, place)
    data = JSON.parse(response.body)

    render json: {
      id: data['Feature'][0]['Id'],
      name: data['Feature'][0]['Name'],
      yomi: data['Feature'][0]['Property']['Yomi'],
      category: data['Feature'][0]['Category'][0],
      tel: data['Feature'][0]['Property']['Tel1'],
      url: data['Feature'][0]['Detail']['PcUrl1'],
      lat: data['Feature'][0]['Geometry']['Coordinates'].split(',')[1],
      lng: data['Feature'][0]['Geometry']['Coordinates'].split(',')[0],
      address: data['Feature'][0]['Property']['Address'],
    }
  end

  YOLP_REVERSE_GEO_CODER_ENDPOINT = 'https://map.yahooapis.jp/geoapi/V1/reverseGeoCoder'.freeze

  # 緯度経度から住所を取得する。
  def yolp_reverse_geo_coder
    place_params = {
      appid: ENV['YAHOO_APP_ID'],
      lat: params[:lat],
      lon: params[:lon],
      output: 'json'
    }

    response = @conn.get(YOLP_REVERSE_GEO_CODER_ENDPOINT, place_params)
    data = JSON.parse(response.body)

    render json: {
      address: data['Feature'][0]['Property']['Address'],
    }
  end

  private

  def yolp_search(extra_params)
    common_params = {
      appid: ENV['YAHOO_APP_ID'],
      query: params[:query],
      device: 'mobile',
      bbox: params[:west_lng] + ',' + params[:south_lat] + ',' + params[:east_lng] + ',' + params[:north_lat],
      results: 30,
      detail: 'simple',
      lat: params[:center_lat],
      lon: params[:center_lng],
      output: 'json'
    }

    request_params = common_params.merge(extra_params)

    response = @conn.get(YOLP_LOCAL_SEARCH_ENDPOINT, request_params)
    data = JSON.parse(response.body)

    if data['Feature'].is_a?(Array)
      places = data['Feature'].map do |place|
        {
          id: place['Id'],
          name: place['Name'],
          category: place['Category'][0],
          lat: place['Geometry']['Coordinates'].split(',')[1],
          lng: place['Geometry']['Coordinates'].split(',')[0],
        }
      end
      render json: places
    else
      render json: { error: 'No results found or unexpected response format' }, status: :bad_request
    end
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

