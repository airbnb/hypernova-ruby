require 'erb'

class DevelopmentModePlugin
  def after_response(current_response, _)
    current_response.each do |name, result|
      current_response[name] = result.merge({ "html" => render(name, result) }) if result["error"]
    end
  end

  private

  def render(name, result)
    <<-HTML
      <div style="background-color: #ff5a5f; color: #fff; padding: 12px;">
        <p style="margin: 0">
          <strong>Development Warning!</strong>
          The <code>#{html_escape(name)}</code> component failed to render with Hypernova. Error stack:
        </p>
	#{ render_stack_trace(stack_trace(result)) }
      </div>
      #{result["html"]}
    HTML
  end

  def render_stack_trace(trace)
    # Put trace that was split in Hypernova back together, verbatim. Sometimes
    # splitting babel errors makes them more confusing.
    # https://github.com/airbnb/hypernova/blob/master/src/utils/BatchManager.js
    text = html_escape(trace.join("\n    "))
    <<-HTML
      <div
        style="white-space: pre-wrap; font-family: monospace; font-size: .95em;"
      >#{text}</div>
    HTML
  end

  def html_escape(string)
    ::ERB::Util.html_escape(string)
  end

  def stack_trace(result)
    result["error"]["stack"] || []
  end
end
