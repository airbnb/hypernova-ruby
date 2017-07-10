require "json"

class Hypernova::BlankRenderer
  def initialize(job)
    @job = job
  end

  def render
    <<-HTML
      <div data-hypernova-key="#{key}" data-hypernova-id="#{id}" data-hypernova-cache="nocache"></div>
      <script type="application/json" data-hypernova-key="#{key}" data-hypernova-id="#{id}"><!--#{encode}--></script>
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

  def id
    @id ||= SecureRandom.uuid
  end
end
