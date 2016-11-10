require "spec_helper"
require "hypernova/blank_renderer"

describe Hypernova::BlankRenderer do
  describe "#render" do
    let(:job) do
      {
        data: {
          bombs: 2,
          missiles: 3,
        },
        name: "tie fighter",
      }
    end

    it "renders blank html" do
      allow(SecureRandom).to receive(:uuid).and_return("uuid")

      html = described_class.new(job).render
      expect(html).to eq(blank_html(job))
    end

    it "uses the same id for the div and the script tag" do
      blank_renderer = described_class.new(job)
      html = blank_renderer.render
      id = blank_renderer.send(:id)

      expect(html).to match(/<div.*data-hypernova-id="#{id}"/)
      expect(html).to match(/<script.*data-hypernova-id="#{id}"/)
    end

    it "encodes data correctly" do
      str = described_class.new({
        data: {
          foo: '</script>',
          bar: '&gt;',
          baz: '&amp;',
        }
      }).send(:encode)

      expect(str).to match(/<\/script&gt;/)
      expect(str).to match(/&amp;gt;/)
      expect(str).to match(/&amp;amp;/)
    end
  end

  def blank_html(job, stack_trace = [])
    data = job[:data]
    name = job[:name]
    key = name.gsub(/\W/, "")
    id = "uuid"
    json_data = described_class.new(job).send(:encode)

    <<-HTML
      <div data-hypernova-key="#{key}" data-hypernova-id="#{id}"></div>
      <script type="application/json" data-hypernova-key="#{key}" data-hypernova-id="#{id}"><!--#{json_data}--></script>
    HTML
  end
end
