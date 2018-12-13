require "hypernova/batch_renderer"
require "hypernova/parsed_response"
require "hypernova/plugin_helper"

class Hypernova::RequestService
  include Hypernova::PluginHelper

  def render_batch(jobs)
    return render_batch_blank(jobs) if jobs.empty?
    response_body = Hypernova::ParsedResponse.new(jobs).body
    response_body.each do |index_string, resp|
      on_error(build_error(resp["error"]), jobs[index_string]) if resp["error"]
    end
    build_renderer(jobs).render(response_body)
  end

  def render_batch_blank(jobs)
    build_renderer(jobs).render_blank
  end

  private

  def build_error(error)
    {
      'name' => error['name'],
      'message' => error['message'],
      'stack' => error['stack'],
    }
  end

  def build_renderer(jobs)
    Hypernova::BatchRenderer.new(jobs)
  end
end
