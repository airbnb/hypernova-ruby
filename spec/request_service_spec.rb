require "spec_helper"
require "hypernova/request_service"

describe Hypernova::RequestService do
  let(:request_service) { described_class.new }

  describe "#render_batch" do
    context "when jobs are not empty" do
      # You may override these variables
      let(:body) do
        {
          "0" => Helpers.job_success("<h1>Hello World</h1>"),
          "1" => Helpers.job_success("<p>Hello Mars</p>"),
        }
      end

      # Do not override these variables
      let(:batch_renderer) { double("batch_renderer") }
      let(:jobs) do
        {
          "0" => Helpers.args_1,
          "1" => Helpers.args_2,
        }
      end
      let(:parsed_response) { double("parsed_response", body: body) }

      before do
        allow(Hypernova::BatchRenderer).to receive(:new).with(jobs).and_return(batch_renderer)
        allow(Hypernova::ParsedResponse).
          to receive(:new).
          with(jobs).
          and_return(parsed_response)
      end

      context "when there are no errors in the response body" do
        it "calls render on the batch_renderer with a parsed response" do
          expect(batch_renderer).to receive(:render).with(body)
          request_service.render_batch(jobs)
        end
      end

      context "when there are errors in the response body" do
        let(:body) do
          {
            "0" => Helpers.job_success("<h1>Hello World</h1>"),
            "1" => Helpers.job_failure(500),
          }
        end

        it "calls on_error for each job where the response has an error with a new hash" do
          class Plugin
            def on_error(error, job, jobs_hash)
              [error.message, job, jobs_hash]
            end
          end

          plugin = Plugin.new
          Hypernova.add_plugin!(plugin)

          error_from_response = body["1"]["error"]

          allow(batch_renderer).to receive(:render).with(body)

          expect(plugin).to receive(:on_error).with(error_from_response, jobs["1"], nil)
          request_service.render_batch(jobs)
        end
      end
    end

    context "when jobs are empty" do
      it "uses BatchRenderer to render data with blank HTML" do
        jobs = []
        expect(request_service.render_batch(jobs)).to eq(request_service.render_batch_blank(jobs))
      end
    end
  end

  describe "#render_batch_blank" do
    it "uses BatchRenderer to render data with blank HTML" do
      jobs = []
      blank = double("blank")
      batch_renderer = double("batch_renderer", render_blank: blank)
      allow(Hypernova::BatchRenderer).to receive(:new).with(jobs).and_return(batch_renderer)

      expect(request_service.render_batch_blank(jobs)).to eq(blank)
    end
  end
end
