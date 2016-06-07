require "hypernova/batch"
require "hypernova/configuration"
require "hypernova/rails/action_controller"
require "hypernova/version"

module Hypernova
  # thrown by ControllerHelper methods if you don't call hypernova_batch_before first
  class NilBatchError < StandardError; end

  # thrown by Batch#render if your job doesn't have the right keys and stuff.
  class BadJobError < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Hypernova::Configuration.new
    yield(configuration)
  end

  # TODO: more interesting token format?
  RENDER_TOKEN_REGEX = /__hypernova_render_token\[\w+\]__/

  def self.render_token(batch_token)
    "__hypernova_render_token[#{batch_token}]__"
  end

  def self.plugins
    @plugins ||= []
  end

  def self.add_plugin!(plugin)
    plugins << plugin
  end

  ##
  # replace all hypernova tokens in `body` with the render results given by batch_result,
  # using render_token_to_batch_token to map render tokens into batch tokens
  # @param [String] body
  # @param [Hash] render_token_to_batch_token
  # @param respond_to(:[]) batch_result
  def self.replace_tokens_with_result(body, render_token_to_batch_token, batch_result)
    # replace all render tokens in the current response body with the
    # hypernova result for that render.
    return body.gsub(RENDER_TOKEN_REGEX) do |render_token|
      batch_token = render_token_to_batch_token[render_token]
      if batch_token.nil?
        next render_token
      end
      render_result = batch_result[batch_token]
      # replace with that render result.
      next render_result
    end
  end

  ##
  # raises a BadJobError if the job hash is not of the right shape.
  def self.verify_job_shape(job)
    [:name, :data].each do |key|
      if job[key].nil?
        raise BadJobError.new("Hypernova render jobs must have key #{key}")
      end
    end
  end
end
