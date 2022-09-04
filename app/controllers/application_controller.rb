class ApplicationController < ActionController::API
  include ActionController::Cookies
  include SessionsHelper
=begin # TODO ここのコードはログイン後は使えるけど、サインアップができるまでは無くしておく。なぜならユーザーがDBに入ってないと使えないから
  include FirebaseAuth
  before_action :authenticate

  class AuthenticationError < StandardError; end
  rescue_from AuthenticationError, with: :not_authenticated

  def authenticate
    payload = decode(request.headers["Authorization"]&.split&.last)
    raise AuthenticationError unless current_user(payload["user_id"])
  end

  def current_user(user_id = nil)
    @current_user ||= User.find_by(uid: user_id)
  end

  private
  def not_authenticated
    render json: { error: { messages: ["ログインしてください"] } }, status: :unauthorized
  end
=end
end
