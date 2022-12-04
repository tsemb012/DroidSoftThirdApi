require 'rails_helper'

RSpec.describe MapsController, type: :request do
  include AuthenticatedHelper

  let(:headers) { { CONTENT_TYPE: 'application/json', Authorization: 'hoge_token' } }
  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  context 'GET /maps' do
    it 'should return 200' do
      authenticate_stub
      get '/maps#show'#, headers: headers
      expect(response.status).to eq 200
    end
  end
end
