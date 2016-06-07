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
      hash = renderer.render(response)

      expect(hash["a"]).to eq(a_html)
      expect(hash["b"]).to eq(Hypernova::BlankRenderer.new(jobs["b"]).render)
      expect(hash["c"]).to eq(c_html)
    end
  end

  describe "#render_blank" do
    it "returns a hash with the job name as the key and blank HTML as the value" do
      hash = renderer.render_blank
      expect(hash["a"]).to eq(Hypernova::BlankRenderer.new(jobs["a"]).render)
      expect(hash["b"]).to eq(Hypernova::BlankRenderer.new(jobs["b"]).render)
      expect(hash["c"]).to eq(Hypernova::BlankRenderer.new(jobs["c"]).render)
    end
  end
end
