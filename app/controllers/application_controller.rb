class ApplicationController < ActionController::API
  include ActionController::Cookies
  include SessionsHelper
  before_action :certify_token
  attr_accessor :email
  class AuthenticationError < StandardError; end
  rescue_from AuthenticationError, with: :not_authenticated

=begin # なくても困らないようであれば削除するように
  def current_user(user_id = nil) # TODO これは誰が使っているコードなのか？ いらないなら消してしまう。
    @current_user ||= User.find_by(user_id: user_id)
  end
=end

  private

  def certify_token
    begin
      authenticate
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
      render json: { message: 'unauthorized' }, status: 401
    end
  end

  def authenticate
    token = FirebaseToken.new(request.headers["Authorization"])
    firebase_project_id = 'droidsoftthird-2cc9b'
    payload = token.verify(firebase_project_id)
    @email = payload["email"]
  end

end
