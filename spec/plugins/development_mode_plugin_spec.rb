require "spec_helper"
require "hypernova/plugins/development_mode_plugin"

describe DevelopmentModePlugin do
  describe "#after_response" do
    let(:name1) { "Melkor.jsx" }
    let(:name2) { "Noldor.jsx" }
    let(:name3) { "Valar.jsx" }
    let(:result1) { Helpers.job_failure(500) }
    let(:result2) { Helpers.job_success("<h1>Feanor rules</h1>") }
    let(:result3) { Helpers.job_failure(404) }

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

      expect(new_response[name1]["html"]).to eq(render(name1, result1["error"]["stack"]))
      expect(new_response[name2]["html"]).to eq(result2["html"])
      expect(new_response[name3]["html"]).to eq(render(name3, result3["error"]["stack"]))
    end
  end

  def render(name, stack_trace)
    <<-HTML
      <div style="background-color: #ff5a5f; color: #fff; padding: 12px;">
        <p style="margin: 0">
          <strong>Development Warning!</strong>
          The <code>#{name}</code> component failed to render with Hypernova. Error stack:
        </p>
        <ul style="padding: 0 20px">
          <li>#{stack_trace.join("</li><li>")}</li>
        </ul>
      </div>
    HTML
  end
end
