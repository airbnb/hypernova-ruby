require "faraday"

class Hypernova::Configuration
  VALID_SCHEMES = [:http, :https].freeze

  attr_accessor :http_adapter,
                :http_client,
                :host,
                :open_timeout,
                :port,
                :scheme,
                :timeout

  def initialize
    @open_timeout = 0.1
    @scheme = :http
    @timeout = 0.6
  end

  def http_adapter
    @http_adapter || Faraday.default_adapter
  end

  def scheme=(value)
    validate_scheme!(value)
    @scheme = value
  end

  private

  def validate_scheme!(value)
    raise TypeError.new("Unknown scheme #{value}") unless VALID_SCHEMES.include?(value)
  end
end
