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

# Set here YOUR_APP_PRIVATE_KEY_IN_PEM_FORMAT_BASE64_URLSAFE_ENCODED
private_keychain = {
  :'pseudo-applogic' => OpenSSL::PKey.read(Base64.urlsafe_decode64('LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBeTlnZ2pIS0RMS056RVVyN1BqQitGZU9TVHl6ckV4VTd6bVl1d1FNaXhzWHdhdlRxCmx3Um00WEZqSjhtcktrQ1luaTZ3aWpzSjBmMi8rRU9SUTJOSk1MeEZ0MUtwVXNzcXFMdjlhbjFVUWJvaURLUWwKZ0lOQVdiSDF6ZmtHdlVFdENEUkJOMUFyc1hFNWxyZ2NuNEFNb05LcUZiNUtsNXdBV2llcGVQdWUrdFlFNGFuNQpuUzlnSUN2N2k4MzdIcEFKWldyMlVuM3IxZ2wyeTNoRXZ6SXd5Y2Vld1ZLNlZINUc4Zk51di9UU1BEZnBJZnNuCk90Y25leXh6MHFCT01kWkRDTk9zUTh1VXhQMUUvclJyRW4vVlBrZ09tZTVqQVYwcFpSUStqM2ZpcC9zNEE2R1AKNFEyL0ZxS1V4bThHYzJwZXFneUZieDZDYXFVZndnK1BiTnNTa1FJREFRQUJBb0lCQVFESStzYmNzdXJ5VUJWYgpyM29YenVnQjNPYWNlY1VzZzNyNy9YT0xpZlAzMTZFN1UwOFlwcFpwSU1xS3FDUEMvUDE4dUx3SERqNllkSCtaCjM4U1JsSXJOS2xQeWMrWE9ZOUlqbTNZNFVHbUtoR0tkNUJtMW83TUd2SmVHQlVuSHYwTVBHN1pST3hKWldURlcKa1NCbmduRHcvOFFDdkNQL1p5aFJ1MWswbDZJZjNMRXhRdGhWMlNRNHpWY25CUU1WKytseVkyTTM5SldyNzJjSgpFL25pdGdOa3duZ081Nko4aTlDMmZhMnZ1TkVzdDlPQURiTkdlRUU2RWZQbGZSV3VWdGx2N2luejVNQjhodVZXCnpTZ0VBSXUxM25qNmV4eTRBRm1ZdVFyTHJrWk4xUE5yNDFmbEtVM3NOdGpXcjNkZVoybGtEUzAyTmVycTJYT1kKNlVkcnlLR0JBb0dCQU92bWtuMVV4RFNoRFV4dEw1UmQ0WEZPbVFzZXNZTU9DRGVRT1dDOTlTbS9vM3htOUo3YgppVnpYOEpVQ25ZYXN4a2lzRGExaFdldWlKTlNRQTdoOElaZHZodjVTeEw1VG92cE11TllSWHFicGovaXZXRWlVClR6dWdhRTA1eFBES1dpRjFxVUF4VzZidlpuamw1STBuNUZURUNEM2RBQWRibFZqak01OG9DSW5WQW9HQkFOMDIKV0dQd1BNckJnN3BLWjVldGdyTG82QlUvanQzOHNZWEFNYW1BVGNVYWFMd1JhRFpsaU5CYkxxc0lGV1hZWHJROQpJQ1NhK1FrUU1yUWVJSHlQNkUxZjVzM3grNUdRaXYvZlpFWnRsbVBXbUtZWHhHR0pmeExJbjRFZHNKZHNmME8vCmk3V2RmMzg4S28vRGViY0RkRUkwNlQwaE5aVHpWOHM4TG5Cc1VHZk5Bb0dCQUl6R3pvam91eVpGTGpCN3dEY2sKUjFOYytrditoeVNValNiTGROSmN5aCtkODZ4YnJJUFlzNEtxZ3pJSm00UXhPeXRITWVwVC9GdDRLYzZJR3hCUApVNlNSczllMkFSOHJ2a2pzM0NrenVHNlhWNG1xNmw1MTAwcmNFU0owNVNobE9hQmFIU1RuejdBeGtjOTRNZ3BpCjBnb2I2bWN3cWNHNlQ4ZjUzbWFPZDNuNUFvR0FQOGpZeWRCT3B5UVBhSnJscmUyZy94ZDdQQTA4azdPMk9GdkgKdGhsQjAzQ2UvSU9FYWhMeTFTbEZscGxaR2ltK2ZQZ1hHWmI1OGV3U3dxN2hMU21Oa1NueThqVXhGYkw0OFhpbgpnRXMvRHdDa3VWZW5EM3pIQUZLSzgzN3RHV3gyY2NGOGRseTRrNlowbTBtQkFnMWo2MmM0VGFFU3d5VTdqbVdHCituR3c2WTBDZ1lBRlBwQlRnVVQzMlBmbTM2OFFwem1PTnpwb0ROenBqZXVnWVExWmlKYjFVSFNYc0p4ajRzcXcKSzk2UDg0NmoxSHBCVWdEZnloYms0RHlnSFZNWHFDUjBtNDdHUVoremdlTy9yekplZ1BGU0xuR0dCYjJTTEVUagptRkJ2SGJYc25RWmZkVDhRSzhoaHVvc2hmenZzZldLNFpyb0xKUDRGaEtTdlFMcWNqNXovemc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo='))
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
