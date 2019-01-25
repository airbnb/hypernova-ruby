require "json"

class Hypernova::BlankRenderer
  def initialize(job)
    @job = job
  end

  def render
    <<-HTML
      <div data-hypernova-key="#{key}" data-hypernova-id="#{id}"#{html_attributes}></div>
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

  def html_attributes
    # handles content_tag()-like options
    attributes = ''
    options = job[:html_options]
    if options && options[:class]
      escaped_value = "#{options[:class]}".gsub(/"/, '&quot;')
      attributes << %{ class="#{escaped_value}"}
    end
    attributes
  end
end
