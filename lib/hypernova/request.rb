require "hypernova/faraday_request"
require "hypernova/http_client_request"

class Hypernova::Request
  def initialize(jobs)
    @jobs = jobs
  end

  def body
    post.body
  end

  private

  attr_reader :jobs

  def payload
    {
      :body => jobs,
      :idempotent => true,
      :request_format => :json,
      :response_format => :json,
    }
  end

  def post
    if Hypernova.configuration.http_client
      Hypernova::HttpClientRequest.post(payload)
    else
      Hypernova::FaradayRequest.post(payload)
    end
  end
end
