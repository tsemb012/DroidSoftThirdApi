class MapsController < ApplicationController
  TEXT_QUERY = 'textquery'
  INDIVIDUAL_FIELDS = 'name,place_id,geometry,types,photos,formatted_address,plus_code'
  DETAIL_FIELD = 'name,type,place_id,formatted_address,geometry,icon_background_color,url,photo,address_component,plus_code'
  before_action :set_conn

  def search_individual
    candidates = get_results('findplacefromtext/json',
                             inputtype: TEXT_QUERY,
                             fields: INDIVIDUAL_FIELDS,
                             input: params[:input],
                             language: params[:language],
                             locationbias: "rectangle:#{params[:south_lat]},#{params[:west_lng]}|#{params[:north_lat]},#{params[:west_lng]}")
    render json: candidates
  end

  def search_by_text
    candidates = get_results('textsearch/json',
                             query: params[:query],
                             location: "#{params[:center_lat]},#{params[:center_lng]}",
                             radius: params[:radius],
                             type: params[:type],
                             region: params[:region],
                             language: params[:language])
    render json: candidates
  end

  def search_nearby
    candidates = get_results('nearbysearch/json',
                             location: "#{params[:center_lat]},#{params[:center_lng]}",
                             radius: params[:radius],
                             type: params[:type],
                             language: params[:language])
    render json: candidates
  end

  def fetch_place_detail
    candidate = get_results('details/json',
                            place_id: params[:place_id],
                            fields: DETAIL_FIELD,
                            language: params[:language])
    render json: candidate
  end

  private

  def set_conn
    @conn = Faraday.new(url: 'https://maps.googleapis.com/maps/api/place/') do |builder|
      builder.request :url_encoded
      builder.response :logger
      builder.adapter Faraday.default_adapter
    end
  end

  def get_results(endpoint, params)
    response = @conn.get(endpoint, params.merge(key: ENV['GOOGLE_API_KEY']))
    data = JSON.parse(response.body)
    data['results']
  end
end
