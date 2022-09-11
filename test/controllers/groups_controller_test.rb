require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @group = groups(:one)
  end

  test "should get index" do
    get groups_url, as: :json
    assert_response :success
  end

  test "should create group" do
    assert_difference('Group.count') do
      post groups_url, params: { group: { city: @group.city, facility_environment: @group.facility_environment, frequency_basis: @group.frequency_basis, frequency_times: @group.frequency_times, image_url: @group.image_url, introduction: @group.introduction, is_same_sexuality: @group.is_same_sexuality, max_age: @group.max_age, max_number: @group.max_number, min_age: @group.min_age, min_number: @group.min_number, name: @group.name, prefecture: @group.prefecture, string: @group.string, type: @group.type } }, as: :json
    end

    assert_response 201
  end

  test "should show group" do
    get group_url(@group), as: :json
    assert_response :success
  end

  test "should update group" do
    patch group_url(@group), params: { group: { city: @group.city, facility_environment: @group.facility_environment, frequency_basis: @group.frequency_basis, frequency_times: @group.frequency_times, image_url: @group.image_url, introduction: @group.introduction, is_same_sexuality: @group.is_same_sexuality, max_age: @group.max_age, max_number: @group.max_number, min_age: @group.min_age, min_number: @group.min_number, name: @group.name, prefecture: @group.prefecture, string: @group.string, type: @group.type } }, as: :json
    assert_response 200
  end

  test "should destroy group" do
    assert_difference('Group.count', -1) do
      delete group_url(@group), as: :json
    end

    assert_response 204
  end
end
