require 'faraday_middleware/response_middleware'

module FaradayMiddleware
  class ParseOj < ResponseMiddleware
    dependency 'oj'
    
    define_parser do |body|
      Oj.load(body, mode: :compat) unless body.strip.empty?
    end
    
    VERSION = '0.3.0'
  end
end

Faraday::Response.register_middleware oj: FaradayMiddleware::ParseOj

# Ruby-like syntax with hash[:snake_cased] symbol keys
module FaradayMiddleware
  class ParseOjToSymbols < ResponseMiddleware
    dependency 'oj'

    define_parser do |body|
      data = Oj.load(body, mode: :compat) unless body.strip.empty?
      if data.respond_to?('deep_transform_keys!')
        data.deep_transform_keys! { |key| key.underscore.to_sym }
      else
        data = {root: data} # Wrap data to ensure deep_transform_keys works
        data.deep_transform_keys! { |key| key.to_s.underscore.to_sym } # Base key may not have been a string
        data = data[:root] # Back to original structure
      end
    end

    VERSION = '0.3.0'
  end
end

Faraday::Response.register_middleware oj_to_symbols: FaradayMiddleware::ParseOjToSymbols
