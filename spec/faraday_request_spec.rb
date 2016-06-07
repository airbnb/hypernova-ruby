require "spec_helper"
require "hypernova/faraday_request"

describe Hypernova::FaradayRequest do
  describe ".post" do
    it "uses Faraday to make a POST request" do
      Hypernova.configure do |config|
        config.host = "arnor.com"
        config.port = 80
      end

      payload = { body: { sword: :narsil } }
      response_body = "<div>The Witch King is alive</div>"

      full_path = [
        Hypernova::BatchUrlBuilder.base_url,
        Hypernova::BatchUrlBuilder.path,
      ].join("")

      stub_request(:post, full_path).
        with({
          body: payload[:body].to_json,
          headers: {
            "Content-Type" => "application/json",
          },
        }).
        to_return(status: 200, body: response_body, headers: {})

      expect(described_class.post(payload).env[:body]).to eq(response_body)
    end
  end
end
