# Requiring SimpleCov and its configuration at the top is important.
# If we do not do this, coverage will only look in the spec/ folder.
require "simplecov"

SimpleCov.minimum_coverage(100)
SimpleCov.start do
  add_filter "lib/hypernova/rails/action_controller.rb"
  add_filter "spec"
end

require "hypernova"
require "pry"
require "rspec"
require "webmock/rspec"

RSpec.configure do |config|
  config.before do |example|
    Hypernova.configure do |config|
      config.http_client = nil
    end
    Hypernova.instance_variable_set("@plugins", [])
  end
end

# hello world
module Helpers
  def self.args_1
    {
      :name => 'dummy_1',
      :data => {
        :dummy => 1,
      },
    }
  end

  def self.args_2
    {
      :name => 'dummy_2',
      :data => {
        :dummy => 2,
      },
    }
  end

  def self.integration_args(data)
    {
      :name => 'HypernovaExampleReact.js',
      :data => data,
    }
  end

  def self.template(first, second)
    "hello #{first}, #{second}!"
  end

  def self.job_success(html)
    {
      'success' => true,
      'html' => html,
      'meta' => {},
      'duration' => 17,
      'statusCode' => 200,
      'error' => nil,
    }
  end

  def self.job_failure_fallback(status)
    {
      'success' => false,
      'html' => '<div>FALLBACK HTML</div>',
      'meta' => {},
      'duration' => 17,
      'statusCode' => status,
      'error' => {
        'name' => 'TypeError',
        'message' => 'You have some error',
        'stack' => [
          'OH NOOOOOO',
        ],
      },
    }
  end

  def self.job_failure(status)
    {
      'success' => false,
      'html' => nil,
      'meta' => {},
      'duration' => 17,
      'statusCode' => status,
      'error' => {
        'name' => 'TypeError',
        'message' => 'You have some error',
        'stack' => [
          'OH NOOOOOO',
        ],
      },
    }
  end

  class Controller
    def self.helper_method(*methods)
      @helper_methods ||= []
      @helper_methods.concat(methods)
    end

    include Hypernova::ControllerHelpers
    attr_accessor :response

    def make_response(body)
      self.response = FakeResponse.new(body)
      return self.response
    end
  end

  class FakeResponse
    attr_accessor :body
    def initialize(the_body)
      self.body = the_body
    end
  end

  class ControllerWithService < Controller
    def hypernova_service
      @service ||= TokenIdentityService.new
    end
  end

  # Bogus example batch service
  class TokenIdentityService
    def render_batch(jobs)
      jobs.keys.inject({}) do |map, k|
        map[k.to_s] = k.to_s
        map
      end
    end

    # This just needs to be here... doesn't have to reflect actual work.
    def render_batch_blank(jobs)
      render_batch(jobs)
    end
  end
end
