require "hypernova/controller_helpers"

if defined?(ActionController::Base)
  ActionController::Base.class_eval do
    include Hypernova::ControllerHelpers

    helper_method :render_react_component
  end
end
