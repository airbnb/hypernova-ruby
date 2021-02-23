require "spec_helper"
require "hypernova/faraday_connection"

describe Hypernova::FaradayConnection do
  describe ".build" do
    it "instantiates a Faraday object" do
      http_adapter = Faraday.default_adapter

      Hypernova.configure do |config|
        config.http_adapter = http_adapter
      end

      expect(Faraday).
        to receive(:new).
        with({
          request: {
            open_timeout: Hypernova.configuration.open_timeout,
            timeout: Hypernova.configuration.timeout,
          },
          url: Hypernova::BatchUrlBuilder.base_url,
        }).
        and_call_original

      expect(described_class.build.builder.adapter).to eq(Faraday::Adapter::NetHttp)
    end
  end
end
