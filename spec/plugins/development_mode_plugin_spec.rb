require "spec_helper"
require "hypernova/plugins/development_mode_plugin"

describe Hypernova::DevelopmentModePlugin do
  describe "#after_response" do
    let(:name1) { "Melkor.jsx" }
    let(:name2) { "Noldor.jsx" }
    let(:name3) { "Valar.jsx" }
    let(:result1) { Helpers.job_failure_fallback(500) }
    let(:result2) { Helpers.job_success("<h1>Feanor rules</h1>") }
    let(:result3) { Helpers.job_failure_fallback(404) }

    let(:response) do
      hash = {}
      hash[name1] = result1
      hash[name2] = result2
      hash[name3] = result3
      hash
    end

    it "renders HTML with debugging information for each component that failed" do
      plugin = described_class.new
      new_response = plugin.after_response(response, response)

      expect(new_response[name1]["html"]).to match('<div>FALLBACK HTML</div>')
      expect(new_response[name2]["html"]).to eq(result2["html"])
      expect(new_response[name3]["html"]).to match('<div>FALLBACK HTML</div>')
    end
  end
end
