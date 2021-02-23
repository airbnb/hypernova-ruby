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

      if Gem.loaded_specs['faraday'].version >= Gem::Version.new("1.0.0")
        expect(described_class.build.builder.adapter).to eq(Faraday::Adapter::NetHttp)
      else
        expect(described_class.build.builder.handlers).to include(Faraday::Adapter::NetHttp)
      end
    end
  end
end
