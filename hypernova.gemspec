# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hypernova/version"

Gem::Specification.new do |spec|
  spec.authors = [
    'Jake Teton-Landis',
    'Jordan Harband',
    'Ian Christian Myers',
    'Tommy Dang',
    'Josh Perez'
  ]
  spec.bindir = "exe"
  spec.description = "[deprecated] A Ruby client for the Hypernova service"
  spec.email = %w(
    jake.tl@airbnb.com
    ljharb@gmail.com
    ian.myers@airbnb.com
    tommy.dang@airbnb.com
    josh@goatslacker.com
  )
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.homepage = 'https://github.com/airbnb/hypernova-ruby'
  spec.license = 'MIT'
  spec.name = 'hypernova'
  spec.require_paths = ["lib"]
  spec.summary = %q{Batch interface for Hypernova, the React render service.}
  spec.version = Hypernova::VERSION

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = 'https://rubygems.org'
    spec.metadata['deprecated'] = 'true'
  end

  spec.add_development_dependency "json"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.11"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "webmock", "~> 3.0"

  spec.add_runtime_dependency "faraday", "~> 1"
end
