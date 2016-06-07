require "uri"

class Hypernova::BatchUrlBuilder
  def self.base_url
    configuration = Hypernova.configuration
    builder = configuration.scheme == :https ? URI::HTTPS : URI::HTTP
    builder.build(host: configuration.host, port: configuration.port).to_s
  end

  def self.path
    "/batch"
  end
end
