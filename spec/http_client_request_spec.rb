require "spec_helper"
require "hypernova/http_client_request"

describe Hypernova::HttpClientRequest do
  describe ".post" do
    let(:payload) { { spear: :aeglos } }

    context "when client's post method requires 1 argument" do
      it "calls post on the client" do
        class TestClient
          def post(url, payload = {})
            [200, {}, { destroy: :many }]
          end
        end

        Hypernova.configure do |config|
          config.http_client = TestClient.new
        end

        expect(described_class.post(payload)).to eq([200, {}, { destroy: :many }])
      end
    end

    context "when client's post method does not require 1 argument" do
      it "calls post on the client" do
        class TestClient
          def post(payload = {})
            [200, {}, { destroy: :many }]
          end
        end

        Hypernova.configure do |config|
          config.http_client = TestClient.new
        end

        expect(described_class.post(payload)).to eq([200, {}, { destroy: :many }])
      end
    end
  end
end
