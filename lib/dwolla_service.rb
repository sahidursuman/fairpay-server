# require 'rubygems'
# require 'pp'
# require 'dwolla'
# require 'dwolla_swagger'


class DwollaService



  def initialize
    @endpoint = 'https://uat.dwolla.com'
    @access_token = 'GW4JA1uZmgD53hBasnPDrrUDIoNBgWlvC94pNFfHN74Wngt5lo'
    @refresh_token = 'g6jBojtdQmBjceiXAojRG8BV3RnWQAEdMt5LzcMgZbVsBKV4xi'
    @client_id = 'oIAn4ed1iJmfZr6wiOdmEyjsVQmVHBfjOF701xNt7ns4p2IKDF'
    @client_secret = 'dwTh0TPlycLnvXG0S8dHOJjedSkYEGzNum1cE4Qq0Odf6rdGf0'
  #                   PO+SzGAsZCE4BTG7Cw4OAL40Tpf1008mDjGBSVo6QLNfM4mD+a
    @oauth_redirect_url = 'http://local.fairpay.coop:3000/dwolla/oauth_complete'
    @payment_redirect_url = 'http://local.fairpay.coop:3000/dwolla/payment_complete'

  #  https://example.com/return
  #  scope=Balance%7CAccountInfoFull%7CSend%7CRequest%7CTransactions%7CContacts%7CFunding%7CManageAccount%7CScheduled
#    Dwolla::scope = 'send|transactions|balance|request|contacts|accountinfofull|funding'
    # @scope = "Send%7CRequest%7CFunding"
    @scope = "Send|Funding|Balance"

    @code = "DwXCDA2nmzSJFPl7MEGwlMXTYoGs"


    @dwolla = DwollaV2::Client.new(id: @client_id, secret: @client_secret) do |optional_config|
      optional_config.environment = :sandbox
      optional_config.on_grant do |token|
        p "dwollav2.on_grant - token: #{token}"
        # YourTokenData.create! token
        DwollaToken.create! token
      end
    end

    @auth = DwollaV2::Auth.new(@dwolla, {scope: @scope})

  end

  def api_client
    @dwolla
  end

  def reset_api_config
    # ::Dwolla::api_key = @api_key
    # ::Dwolla::api_secret = @api_secret
    # ::Dwolla::scope = @scope
    #
    #
    DwollaSwagger::Swagger.configure do |config|
      config.access_token = @client_id
      config.host = 'api-uat.dwolla.com'
      config.base_path = '/'
    end
  end

  def auth
    @dwolla.auths.new(redirect_url: @redirect_url, scope: @scope)
  end

  def auth_url
    # reset_api_config
    # url = ::Dwolla::OAuth.get_auth_url(@oauth_redirect_url)
    url = "#{@endpoint}/oauth/v2/authenticate?client_id=#{@client_id}&response_type=code&redirect_uri=#{@redirect_url}&scope=#{@scope}"

    # auth = DwollaV2::Auth.new(c, {scope: @scope})
    auth.url
  end

  def auth_callback(params)
    token = auth.callback(params)
    p "auth_callback - token: #{token}";
    token
  end

  def exchange_code_for_token(code)
    token = auth.callback({code: code})
    #
    # reset_api_config
    # # token = ::Dwolla::OAuth.get_token(code, @oauth_redirect_url)
    # params = {
    #     client_id: @client_id,
    #     client_secret: @client_secret,
    #     code: code,
    #     grant_type: "authorization_code",
    #     redirect_uri: @oauth_redirect_url
    # }
    # DwollaSwagger::RootApi.oauth(params)
    #
    # # "Your never-expiring OAuth access token is: <b>#{token}</b>"
    #
  end

  def token_for_account_id(account_id)
    data = DwollaToken.find_by(account_id: account_id)
    token = @dwolla.tokens.new data
  end

  # handy for console testing
  def last_token
    @dwolla.tokens.new DwollaToken.last
  end

  def list_funding_sources(token)
    raw = token.get "/accounts/#{token.account_id}/funding-sources"
    puts "raw: #{raw.to_json}"
    result = {}
    raw[:_embedded][:'funding-sources'].each do |data|
      p "data: #{data}"
      result[data[:name]] = data[:_links][:self][:href]
    end
    result
  end


  def send(token, funding_source, destination, amount)
    payload = {
        _links: {
            destination: {href: destination},
            source: {href: funding_source}
        },
        amount: {currency: 'USD', value: amount}
    }
    token.post '/transfers', payload
  end


end