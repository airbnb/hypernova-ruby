require "json"

class Hypernova::BlankRenderer
  def initialize(job)
    @job = job
  end

  def render
    <<-HTML
      <div data-hypernova-key="#{key}"></div>
      <script type="application/json" data-hypernova-key="#{key}"><!--#{encode}--></script>
    HTML
  end

  private

  attr_reader :job

  def data
    job[:data]
  end

  def encode
    JSON.generate(data).gsub(/&/, '&amp;').gsub(/>/, '&gt;')
  end

  def key
    name.gsub(/\W/, "")
  end

  def name
    job[:name]
  end
end
