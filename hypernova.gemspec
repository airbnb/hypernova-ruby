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
  spec.description = "A Ruby client for the Hypernova service"
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
  end

  spec.add_development_dependency "json", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.11"
  spec.add_development_dependency "pry", "~> 0.10"
  # this is pinned because ruby devs hate semver
  # see https://github.com/bblimke/webmock/issues/667
  spec.add_development_dependency "webmock", "=2.1.0"
  # below works around travis-ci requiring github-pages-health-check, whose subdep public_suffix
  # stopped being compatible with ruby 1.9
  # see https://github.com/weppos/publicsuffix-ruby/issues/127
  spec.add_development_dependency "public_suffix", "=1.4.6"

  spec.add_runtime_dependency "faraday", "~> 0.8"
end
