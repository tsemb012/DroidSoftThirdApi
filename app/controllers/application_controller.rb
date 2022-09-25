class ApplicationController < ActionController::API
  include ActionController::Cookies
  include SessionsHelper
  before_action :authenticate
  attr_accessor :user_id, :email
  class AuthenticationError < StandardError; end
  rescue_from AuthenticationError, with: :not_authenticated

  def authenticate
    token = FirebaseToken.new(request.headers["Authorization"])
    firebase_project_id = 'droidsoftthird-2cc9b'
    payload = token.verify(firebase_project_id)
    @user_id = payload["user_id"]
    @email = payload["email"]
  end

  def current_user(user_id = nil)
    @current_user ||= User.find_by(id: user_id)
  end

  private
  def not_authenticated
    render json: { error: { messages: ["ログインしてください"] } }, status: :unauthorized
  end
end
