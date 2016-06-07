require "hypernova/faraday_connection"

class Hypernova::FaradayRequest
  def self.post(payload)
    Hypernova::FaradayConnection.build.post do |request|
      request.url(Hypernova::BatchUrlBuilder.path)
      request.headers["Content-Type"] = "application/json"
      request.body = payload[:body].to_json
    end
  end
end
