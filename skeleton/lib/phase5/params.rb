require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    def initialize(req, route_params = {})
      @params = route_params
      parse_www_encoded_form(req.query_string) if !!req.query_string
      parse_www_encoded_form(req.body) if !!req.body
    end

    def [](key)
      str_key = key.is_a?(Symbol) ? key.to_s : key
      @params[str_key]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      parsed_url = URI.decode_www_form(www_encoded_form)
      parsed_url.each do |key_val_pair|
        parsed_key = parse_key(key_val_pair[0])
        top_level_key = parsed_key.shift
        param_hash = recursive_param(parsed_key += [key_val_pair[1]])

        @params[top_level_key] = param_hash
      end
    end

    def parse_key(key)
      key.split(/\]\[|\[|\]/)
    end

    def recursive_param(arr)
      curr_level = arr.shift

      return curr_level if arr.count == 0
      return { curr_level => recursive_param(arr)}
    end
  end
end
