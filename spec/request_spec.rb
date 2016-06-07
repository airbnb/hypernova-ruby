require "spec_helper"
require "hypernova/request"

describe Hypernova::Request do
  describe "#body" do
    let(:body) { { dead_orcs: 300 } }
    let(:jobs) { double("jobs") }
    let(:payload) do
      {
        body: jobs,
        idempotent: true,
        request_format: :json,
        response_format: :json,
      }
    end
    let(:response) { double("response", body: body) }

    context "when Hypernova is configured to use an http_client" do
      it "calls post on Hypernova::HttpClientRequest" do
        Hypernova.configure { |config| config.http_client = double("http_client") }

        allow(Hypernova::HttpClientRequest).to receive(:post).and_return(response)
        expect(Hypernova::HttpClientRequest).to receive(:post).with(payload)
        expect(described_class.new(jobs).body).to eq(response.body)
      end
    end

    context "when Hypernova is not configured to use an http_client" do
      it "calls post on Hypernova::FaradayRequest" do
        allow(Hypernova::FaradayRequest).to receive(:post).and_return(response)
        expect(Hypernova::FaradayRequest).to receive(:post).with(payload)
        expect(described_class.new(jobs).body).to eq(response.body)
      end
    end
  end
end
