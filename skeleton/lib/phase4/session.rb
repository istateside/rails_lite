require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      @req_cookie = req.cookies.find { |c| c.name == '_rails_lite_app'}
      @session = (!!@req_cookie ? JSON.parse(@req_cookie.value) : {})
    end

    def [](key)
      @session[key]
    end

    def []=(key, val)
      @session[key] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      res.cookies << WEBrick::Cookie.new(
        '_rails_lite_app', @session.to_json
      )
    end
  end
end
