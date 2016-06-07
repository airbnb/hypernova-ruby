require "hypernova/request"
require "hypernova/response"

class Hypernova::ParsedResponse
  def initialize(jobs)
    @jobs = jobs
  end

  def body
    response.parsed_body
  end

  private

  attr_reader :jobs

  def request
    Hypernova::Request.new(jobs)
  end

  def response
    Hypernova::Response.new(request)
  end
end
