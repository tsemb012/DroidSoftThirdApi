require 'base64'

class FirebaseToken
  JWT_ALGORITHM = 'RS256'.freeze
  PUBLIC_KEY_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'.freeze

  def initialize(token)
    @token = token
  end

  def verify(firebase_project_id)
    encoded_header, encoded_payload, jwt_signature = @token.split('.')
    header = decode_header(encoded_header)#ヘッダーから必要な情報を取得する。
    alg = header['alg']
    kid = header['kid']

    if alg != JWT_ALGORITHM
      raise "Invalid token 'alg' header (#{alg}). Must be '#{JWT_ALGORITHM}'."
    end

    public_key = get_public_key(kid) #kidから公開鍵を取得する。
    if verify_jwt(@token, public_key, firebase_project_id)
        decode_payload(encoded_payload)
      else
        raise "Invalid token."
    end

  end

  private

  def decode_header(encoded_header) # headerから取得したトークンを解析する
    JSON.parse(Base64.decode64(encoded_header))
  end

  def decode_payload(encoded_payload) # headerから取得したトークンを解析する
    JSON.parse(Base64.urlsafe_decode64(encoded_payload))
  end



  def get_public_key(kid)
    response = HTTParty.get(PUBLIC_KEY_URL)

    unless response.success?
      raise "Failed to fetch JWT public keys from Google."
    end

    public_keys = response.parsed_response
    # cache public_keys to avoid downloading it every time.
    # Use the cache-control header for TTL.
    unless public_keys.key?(kid)
      raise "Invalid token 'kid' header, do not correspond to valid public keys."
    end

    OpenSSL::X509::Certificate.new(public_keys[kid]).public_key
  end

  def verify_jwt(token, public_key, firebase_project_id)
    options = {
      algorithm: JWT_ALGORITHM,
      iss: "https://securetoken.google.com/#{firebase_project_id}",
      verify_iss: true,
      aud: firebase_project_id,
      verify_aud: true,
      verify_iat: true,
    }
    JWT.decode(token, public_key, true, options)
  end
end

#TODO id_token をAndroid側から取得する。
#token = FirebaseToken.new(id_token)
#decoded_token = token.verify(firebase_project_id)#TODO 他の情報はリクエストから取得されているけど、リクエストはどこからきているのか？
#p decoded_token