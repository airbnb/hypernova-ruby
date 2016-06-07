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

    context "when there are plugins" do
      context "when plugins have the after_response method" do
        class Plugin1
          def after_response(current_response, original_response)
            current_response.merge({
              death_choke: false,
              original_response_1: original_response,
            })
          end
        end

        class Plugin2
          def after_response(current_response, original_response)
            current_response.merge({
              force_lightning: true,
              original_response_2: original_response,
            })
          end
        end

        it "parses the JSON from the POST request and loops through all the plugins" do
          plugin_1 = Plugin1.new
          plugin_2 = Plugin2.new
          plugin_3 = Plugin2.new

          Hypernova.add_plugin!(plugin_1)
          Hypernova.add_plugin!(plugin_2)
          Hypernova.add_plugin!(plugin_3)

          original_response = JSON.parse(body)

          expect(response.parsed_body).
            to eq(
              original_response.merge({
                death_choke: false,
                force_lightning: true,
                original_response_1: original_response,
                original_response_2: original_response,
              })
            )
        end
      end

      context "when a plugin does not have an after_response method" do
        it "parses the JSON from the POST request and loops through all the plugins" do
          class Plugin3
          end

          plugin_3 = Plugin3.new

          Hypernova.add_plugin!(plugin_3)

          expect(response.parsed_body).to eq(JSON.parse(body))
        end
      end
    end
  end
end
