module AuthenticatedHelper
  def authenticate_stub
    # 渡したいインスタンス変数を定義
    @user_info = [
      {
        'name' => 'kosuke',
        'email' => 'kosuke@example.com',
        'email_verified' => true,
      }
    ]

    # allow_any_instance_ofメソッドを使ってauthenticate!メソッドが呼ばれたら
    # ↑のインスタンス変数を返す
    allow_any_instance_of(ApplicationController).to receive(:certify_token).and_return(@user_info)
  end
end
