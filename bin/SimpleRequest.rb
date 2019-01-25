require 'openssl'
require 'jwt-multisig'
require 'base64'
require 'json'
require 'faraday'
require 'faraday_middleware'

payload = { 
  exp:  1922830281, # Put here all the JWT claims.
  data: { foo: 'bar', baz: 'qux' } # Put here all the data your API action expects.
}

# You can choose what signatures the JWT should include.
# Set env variable before execute!! YOUR_APP_PRIVATE_KEY_IN_PEM_FORMAT_BASE64_URLSAFE_ENCODED
private_keychain = {
  :'pseudo-applogic' => OpenSSL::PKey.read(Base64.urlsafe_decode64(ENV['PRIVATE_RSA_KEY']))
}

algorithms = {
  :'pseudo-applogic' => 'RS256',
}

jwt = JWT::Multisig.generate_jwt(payload, private_keychain, algorithms)

Kernel.puts JSON.dump(jwt) # The output will include serialized JWT.

# Save your JWT in data.json
File.open('./data.json','w') do |f|
  f.write(jwt.to_json)
end

data = File.read('./data.json')

#Create HTTP request with ruby Faraday client library 
module Faraday
  class Connection
    alias original_run_request run_request
    def run_request(method, url, body, headers, &block)
      original_run_request(method, url, body, headers, &block).tap do |response|
        response.env.instance_variable_set :@request_body, body if body
      end
    end
  end
end

def http_client
  Faraday.new(url: @root_api_url) do |conn|
    conn.request :json
    conn.response :json
    conn.adapter Faraday.default_adapter
  end
end

# The output will include request response
pp http_client
  .public_send(:post,'http://peatio.app.local:8080/api/v2/management/timestamp', data)
  .body
