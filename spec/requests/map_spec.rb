require 'rails_helper'

RSpec.describe MapsController, type: :request do
  include AuthenticatedHelper

  let(:headers) { { CONTENT_TYPE: 'application/json', Authorization: 'hoge_token' } }
  before do
    authenticate_stub

  end

  after do
    # Do nothing
  end

  context 'GET /search_query' do #曖昧検索の範囲をどこまでひろげのか？
    # 以下のサイトを見て「場所の検索」を実行する
    # https://developers.google.com/maps/documentation/places/web-service/search-find-place#maps_http_places_findplacefromtext_locationbias-rb
    it 'should return 200' do
      get '/maps/search_query#search_query', params: {
        input: 'ラーメン',
        view_port: {
              south_west: {
                  south: 35.658581,
                  west: 139.745433
              },
              north_east: {
                  north: 35.659281,
                  east: 139.746433
              }
          },
        language: 'ja',

      }#, headers: headers
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(json['candidates'][0]['name']).to eq('東京都')
    end
  end

  context 'GET /search_text' do
    # 以下のサイトを見て「テキスト検索」を実行する
    # https://developers.google.com/maps/documentation/places/web-service/search-text
    # Typeは下記サイトを参照
    # https://developers.google.com/maps/documentation/places/web-service/supported_types
    # 使用できるtypeは全てを満たさないので、下記の方法で対応を検討する。
    # スクレイピングによる情報の取得。キーワードの組み合わせによる検索
    it 'should return 200' do
      get '/maps/text#search_text',
          params: {
            query: '東京都',
            type: 'library',
            keyword: '図書館',
          }
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
    end

    it 'should return 200' do
      get '/maps/text#search_text',
          params: {
            query: '東京都',
            type: 'restaurant',
            keyword: 'ラーメン',
            radius: '500',
            region: 'jp',
            location: '35.658581,139.745433',
          }
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
    end

  end

  context 'GET /search_nearby' do
    # 以下のサイトを見て「近くの場所を検索」を実行する
    # https://developers.google.com/maps/documentation/places/web-service/search-nearby
    # Typeは下記サイトを参照
    # https://developers.google.com/maps/documentation/places/web-service/supported_types
    # 使用できるtypeは全てを満たさないので、下記の方法で対応を検討する。
    # スクレイピングによる情報の取得。キーワードの組み合わせによる検索
    it 'should return 200' do
      get '/maps/near_by#search_nearby',
          params: {
            location: '35.658581,139.745433',
            radius: '500',
            type: 'library',
            keyword: '図書館',
            rankby: 'distance' #|'prominence'
          }
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
    end

    it 'should return 200' do
      get '/maps/near_by#search_nearby',
          params: {
            location: '35.658581,139.745433',
            radius: '500',
            type: 'restaurant',
            keyword: 'ラーメン',
          }
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
    end

    #周辺検索の範囲をどこまでひろげのか？
=begin
Nearby Search リクエストを keyword（または name）パラメータを指定せずに使用すると、付近の施設を検索できます。サポートされているいずれかの場所タイプ（表 1: 場所タイプを参照）と組み合わせた type パラメータも使用することをおすすめします。これにより、query パラメータが空または欠落している Text Search リクエストの現在の動作に最も近い動作となります。
これが、場所指定のもの　→　
=end
  end

  context 'GET /maps/place_detail' do
    # 以下のサイトを見て「場所の詳細情報を取得」を実行する
    # https://developers.google.com/maps/documentation/places/web-service/details
    it 'should return 200' do
      get '/maps/place_detail#place_detail',
          params: {
            place_id: 'ChIJN1t_tDeuEmsRUsoyG83frY4',
            fields: 'name,formatted_address,geometry,icon,opening_hours,photos,place_id,plus_code,types'
          }
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
    end
  end



  context  do

    # 取得した特定の位置情報から住所などの詳細な情報を逆引きする。

  end

  context do
    # 現在指しているpinの場所をスケジュールに登録する。
    # どこまでの情報を登録するのか。

  end
end
