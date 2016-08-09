require "json"

class Hypernova::Response
  def initialize(request)
    @request = request
  end

  # Example parsed body with no error:
  # {
  #   "0" => {
  #     "name" => "hello_world.js",
  #     "html" => "<div>Hello World</div>",
  #     "meta" => {},
  #     "duration" => 100,
  #     "statusCode" => 200,
  #     "success" => true,
  #     "error" => nil,
  #   }
  # }

  # Example parsed body with error:
  # {
  #   "0" => {
  #     "html" => "<p>Error!</p>",
  #     "name" => "goodbye_galaxy.js",
  #     "meta" => {},
  #     "duration" => 100,
  #     "statusCode" => 500,
  #     "success" => false,
  #     "error" => {
  #       "name" => "TypeError",
  #       "message" => "Cannot read property 'forEach' of undefined",
  #       "stack" => [
  #         "TypeError: Cannot read property 'forEach' of undefined",
  #         "at TravelerLanding.componentWillMount",
  #         "at ReactCompositeComponentMixin.mountComponent",
  #       ],
  #     },
  #   }
  # }
  def parsed_body
    response = parse_body
    # This enables backward compatibility with the old server response format.
    # In the new format, the response results are contained within a "results" key. The top level
    # hash contains a "success" and "error" which relates to the whole batch.
    response = response["results"] || response
  end

  private

  attr_reader :request

  def body
    request.body
  end

  def parse_body
    JSON.parse(body)
  end
end
