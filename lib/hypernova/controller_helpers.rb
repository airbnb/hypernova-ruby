require "hypernova/plugin_helper"
require "hypernova/request_service"

module Hypernova
  ##
  # Mixin.
  # Implements the high-level rails helper interface.
  # Currently untested.
  module ControllerHelpers
    include Hypernova::PluginHelper

    ##
    # a Rails around_filter to support hypernova batch rendering.
    def hypernova_render_support
      hypernova_batch_before
      yield
      hypernova_batch_after
    end

    ##
    # enqueue a render into the current request's hypernova batch
    def hypernova_batch_render(job)
      if @hypernova_batch.nil?
        raise NilBatchError.new('called hypernova_batch_render without calling '\
          'hypernova_batch_before. Check your around_filter for :hypernova_render_support')
      end
      batch_token = @hypernova_batch.render(job)
      template_safe_token = Hypernova.render_token(batch_token)
      @hypernova_batch_mapping[template_safe_token] = batch_token
      template_safe_token
    end

    ##
    # shortcut method to render a react component
    # @param [String] name the hypernova bundle name, like 'packages/p3/foo.bundle.js' (for now)
    # @param [Hash] props the props to be passed to the component
    # :^)k|8 <-- this is a chill peep riding a skateboard
    def render_react_component(component, data = {})
      begin
        new_data = get_view_data(component, data)
      rescue StandardError => e
        on_error(e)
        new_data = data
      end
      job = {
        :data => new_data,
        :name => component,
      }

      hypernova_batch_render(job)
    end

    ##
    # Retrieve a handle to a hypernova service
    # OVERRIDE IN YOUR IMPLEMENTATION CLASS TO GET A DIFFERENT SERVICE
    def hypernova_service
      @_hypernova_service ||= Hypernova::RequestService.new
    end

    private

    ##
    # set up a new hypernova batch for this request.
    # The batch's service is provided by instance method #hypernova_service
    # which you should override after including this mixin.
    def hypernova_batch_before
      @hypernova_batch = Hypernova::Batch.new(hypernova_service)
      @hypernova_batch_mapping = {}
    end

    ##
    # Modifies response.body to have all batched hypernova render results
    def hypernova_batch_after
      if @hypernova_batch.nil?
        raise NilBatchError.new('called hypernova_batch_after without calling '\
          'hypernova_batch_before. Check your around_filter for :hypernova_render_support')
      end
      return if @hypernova_batch.empty?

      jobs = @hypernova_batch.jobs
      hash = jobs.each_with_object({}) do |job, h|
        h[job[:name]] = job
      end
      hash = prepare_request(hash, hash)
      if send_request?(hash)
        begin
          will_send_request(hash)
          result = @hypernova_batch.submit!
          on_success(result, hash)
        rescue StandardError => e
          on_error(e, nil, hash)
          result = @hypernova_batch.submit_fallback!
        end
      else
        result = @hypernova_batch.submit_fallback!
      end

      new_body = Hypernova.replace_tokens_with_result(
        response.body,
        @hypernova_batch_mapping,
        result
      )
      response.body = new_body
    end
  end
end
