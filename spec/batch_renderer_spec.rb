require "spec_helper"
require "hypernova/batch_renderer"

describe Hypernova::BatchRenderer do
  # Do not override these variables
  let(:a_html) { "Here is a!" }
  let(:c_html) { "Here is c!" }
  let(:jobs) do
    {
      "a" => Helpers.args_1,
      "b" => Helpers.args_2,
      "c" => Helpers.args_1,
    }
  end
  let(:renderer) { described_class.new(jobs) }

  describe "#render" do
    let(:failed_job) { Helpers.job_failure(404) }
    let(:response) do
      {
        "a" => Helpers.job_success(a_html),
        "b" => failed_job,
        "c" => Helpers.job_success(c_html),
      }
    end

    it "returns a hash with the job name as the key and the HTML as the value" do
      allow(SecureRandom).to receive(:uuid).and_return("uuid")

      hash = renderer.render(response)

      expect(hash["a"]).to eq(a_html)
      expect(hash["b"]).to eq(Hypernova::BlankRenderer.new(jobs["b"]).render)
      expect(hash["c"]).to eq(c_html)
    end

    it "calls after_response if there is a plugin" do
      class Plugin2
        def after_response(current_response, original_response)
          current_response.merge({
            force_lightning: {
              'html' => 'palpatine',
            },
            original_response_2: original_response,
          })
        end
      end

      plugin_2 = Plugin2.new
      Hypernova.add_plugin!(plugin_2)
      hash = renderer.render(response)

      expect(hash[:force_lightning]).to eq('palpatine')
    end

    it "does not have after_response" do
      allow(SecureRandom).to receive(:uuid).and_return("uuid")

      class Plugin3
      end

      plugin_3 = Plugin3.new
      Hypernova.add_plugin!(plugin_3)
      hash = renderer.render(response)

      expect(hash["a"]).to eq(a_html)
      expect(hash["b"]).to eq(Hypernova::BlankRenderer.new(jobs["b"]).render)
      expect(hash["c"]).to eq(c_html)
    end
  end

  describe "#render_blank" do
    it "returns a hash with the job name as the key and blank HTML as the value" do
      allow(SecureRandom).to receive(:uuid).and_return("uuid")

      hash = renderer.render_blank
      expect(hash["a"]).to eq(Hypernova::BlankRenderer.new(jobs["a"]).render)
      expect(hash["b"]).to eq(Hypernova::BlankRenderer.new(jobs["b"]).render)
      expect(hash["c"]).to eq(Hypernova::BlankRenderer.new(jobs["c"]).render)
    end
  end
end
