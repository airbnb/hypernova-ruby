require "faraday"
require "hypernova/batch_url_builder"

class Hypernova::FaradayConnection
  def self.build
    configuration = Hypernova.configuration
    Faraday.new(
      request: {
        open_timeout: configuration.open_timeout,
        timeout: configuration.timeout,
      },
      url: Hypernova::BatchUrlBuilder.base_url,
    ) do |builder|
      builder.adapter(configuration.http_adapter) if configuration.http_adapter
    end
  end
end
