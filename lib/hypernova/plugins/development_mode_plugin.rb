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
          The <code>#{name}</code> component failed to render with Hypernova. Error stack:
        </p>
        <ul style="padding: 0 20px">
          <li>#{stack_trace(result).join("</li><li>")}</li>
        </ul>
      </div>
    HTML
  end

  def stack_trace(result)
    result["error"]["stack"] || []
  end
end
