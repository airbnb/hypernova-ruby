require "spec_helper"
require "hypernova/response"

describe Hypernova::Response do
  describe "#parsed_body" do
    let(:body) { { beams: 5 }.to_json }
    let(:request) { double("request", body: body) }
    let(:response) { described_class.new(request) }

    context "when there are no plugins" do
      it "parses the JSON returned from the POST request" do
        expect(response.parsed_body).to eq(JSON.parse(body))
      end
    end
  end
end
