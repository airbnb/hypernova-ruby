require "spec_helper"
require "hypernova/parsed_response"

describe Hypernova::ParsedResponse do
  describe "#body" do
    it "calls parsed_body on the response" do
      jobs = double("jobs")
      parsed_body = double("parsed_body")
      request = double("request")
      response = double("response", parsed_body: parsed_body)

      allow(Hypernova::Request).to receive(:new).with(jobs).and_return(request)
      allow(Hypernova::Response).to receive(:new).with(request).and_return(response)

      expect(described_class.new(jobs).body).to eq(parsed_body)
    end

    it "is backward compatible with the old response" do
      jobs = double("jobs")
      parsed_body = double({
        "results" => [],
      })
      request = double("request")
      response = double("response", parsed_body: parsed_body)

      allow(Hypernova::Request).to receive(:new).with(jobs).and_return(request)
      allow(Hypernova::Response).to receive(:new).with(request).and_return(response)


      expect(described_class.new(jobs).body).to eq(parsed_body)
    end
  end
end
