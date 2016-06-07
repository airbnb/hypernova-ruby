require "spec_helper"

RSpec.describe Hypernova::Configuration do
  describe "#initialize" do
    it "sets default attributes" do
      configuration = described_class.new
      expect(configuration.open_timeout).to eq(0.1)
      expect(configuration.scheme).to eq(:http)
      expect(configuration.timeout).to eq(0.6)
    end
  end

  describe "#http_adapter" do
    context "when there is no http_adapter" do
      it "returns Faraday.default_adapter" do
        expect(described_class.new.http_adapter).to eq(Faraday.default_adapter)
      end
    end

    context "when an http_adapter is set" do
      it "returns the http_adapter" do
        class FakeHttpAdapater
        end

        http_adapter = FakeHttpAdapater.new
        object = described_class.new
        object.http_adapter = http_adapter
        expect(object.http_adapter).to eq(http_adapter)
      end
    end
  end

  describe "#scheme=" do
    context "when setting a valid scheme" do
      described_class::VALID_SCHEMES.each do |scheme|
        it "does not raise an error" do
          expect { described_class.new.scheme = scheme }.not_to raise_error
        end
      end
    end

    context "when setting an invalid scheme" do
      it "raises an error" do
        expect { described_class.new.scheme = :telepathy }.to raise_error(TypeError)
      end
    end
  end
end
