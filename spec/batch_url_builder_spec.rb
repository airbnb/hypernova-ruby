require "spec_helper"
require "hypernova/batch_url_builder"

describe Hypernova::BatchUrlBuilder do
  describe ".base_url" do
    let(:host) { "mordor.com" }
    let(:port) { 1337 }

    context "when Hypernova configured scheme to be :https" do
      it "returns an https URL" do
        Hypernova.configure do |config|
          config.host = host
          config.port = port
          config.scheme = :https
        end

        expect(described_class.base_url).to eq("https://mordor.com:1337")
      end
    end

    context "when Hypernova not configured scheme to be :https" do
      it "returns an http URL" do
        Hypernova.configure do |config|
          config.host = host
          config.port = port
          config.scheme = :http
        end

        expect(described_class.base_url).to eq("http://mordor.com:1337")
      end
    end
  end

  describe ".path" do
    it "returns the correct path" do
      expect(described_class.path).to eq("/batch")
    end
  end
end
