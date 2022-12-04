require 'minitest/autorun'
require 'test_helper'

class MapsControllerTest < ActionDispatch::IntegrationTest

  test "should get show" do
    get maps_url
    assert_response :success
  end

=begin
  Users.ymlで落ちてしまうけど全く関係なくて意味不明　→　他にも必要な情報があるということ？
　チュートリアルで作った箇所が邪魔しているのでは？
=end

end
