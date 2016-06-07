require "hypernova/batch_url_builder"

class Hypernova::HttpClientRequest
  def self.post(payload)
    if is_client_requiring_1_argument?
      client.post(Hypernova::BatchUrlBuilder.path, payload)
    else
      client.post(payload)
    end
  end

  def self.client
    Hypernova.configuration.http_client
  end

  def self.is_client_requiring_1_argument?
    client.method(:post).arity == -2
  end

  private_class_method :client, :is_client_requiring_1_argument?
end
