# hypernova-ruby [![Build Status](https://travis-ci.org/airbnb/hypernova-ruby.svg)](https://travis-ci.org/airbnb/hypernova-ruby)

> A Ruby client for the Hypernova service

## Getting Started

Add this line to your application’s Gemfile:

```ruby
gem 'hypernova'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hypernova


In Rails, create an initializer in `config/initializers/hypernova.rb`.

```ruby
# Really basic configuration only consists of the host and the port
Hypernova.configure do |config|
  config.host = "localhost"
  config.port = 80
end
```

Add an `:around_filter` to your controller so you can opt into Hypernova rendering of view partials.

```ruby
# In my_controller.rb
require 'hypernova'

class MyController < ApplicationController
  around_filter :hypernova_render_support
end
```

Use the following methods to render React components in your view/templates.

```erb
<%=
  render_react_component(
    'MyComponent.js',
    :name => 'Person',
    :color => 'Blue',
    :shape => 'Triangle'
  )
%>
```

## Configuration

You can pass more configuration options to Hypernova.

```ruby
Hypernova.configure do |config|
  config.http_adapter = :patron # Use any adapter supported by Faraday
  config.host = "localhost"
  config.port = 80
  config.open_timeout = 0.1
  config.scheme = :https # Valid schemes include :http and :https
  config.timeout = 0.6
end
```

If you do not want to use `Faraday`, you can configure Hypernova Ruby to use an HTTP client that
responds to `post` and accepts a hash argument.

```ruby
Hypernova.configure do |config|
  # Use your own HTTP client!
  config.http_client = SampleHTTPClient.new
end
```

You can access a lower-level interface to exactly specify the parameters that are sent to the
Hypernova service.

```erb
<% things.each |thing| %>
  <li>
    <%=
      hypernova_batch_render(
        :name => 'your/component/thing.bundle.js',
        :data => thing
      )
    %>
  </li>
<% end %>
```

You can also use the batch interface if you want to create and submit batches yourself:

```ruby
batch = Hypernova::Batch.new(service)

# each job in a hypernova render batch is identified by a token
# this allows retrieval of unordered jobs
token = batch.render(
  :name => 'some_bundle.bundle.js',
  :data => {foo: 1, bar: 2}
)
token2 = batch.render(
  :name => 'some_bundle.bundle.js',
  :data => {foo: 2, bar: 1}
)
# now we can submit the batch job and await its results
# this blocks, and takes a significant time in round trips, so try to only
# use it once per request!
result = batch.submit!

# ok now we can access our rendered strings.
foo1 = result[token].html_safe
foo2 = result[token2].html_safe
```

## Plugins

Hypernova enables you to control and alter requests at different stages of
the render lifecycle via a plugin system.

### Example

All methods on a plugin are optional, and they are listed in the order that
they are called.

**initializers/hypernova.rb:**
```ruby
# initializers/hypernova.rb
require 'hypernova'

class HypernovaPlugin
  # get_view_data allows you to alter the data given to any individual
  # component being rendered.
  # component is the name of the component being rendered.
  # data is the data being given to the component.
  def get_view_data(component_name, data)
    phrase_hash = data[:phrases]
    data[:phrases].keys.each do |phrase_key|
      phrase_hash[phrase_key] = "test phrase"
    end
    data
  end

  # prepare_request allows you to alter the request object in any way that you
  # need.
  # Unless manipulated by another plugin, request takes the shape:
  # { 'component_name.js': { :name => 'component_name.js', :data => {} } }
  def prepare_request(current_request, original_request)
    current_request.keys.each do |key|
      phrase_hash = req[key][:data][:phrases]
      if phrase_hash.present?
        phrase_hash.keys.each do |phrase_key|
          phrase_hash[phrase_key] = phrase_hash[phrase_key].upcase
        end
      end
    end
    current_request
  end

  # send_request? allows you to determine whether a request should continue
  # on to the hypernova server.  Returning false prevents the request from
  # occurring, and results in the fallback html.
  def send_request?(request)
    true
  end

  # after_response gives you a chance to alter the response from hypernova.
  # This will be most useful for altering the resulting html field, and special
  # handling of any potential errors.
  # res is a Hash like { 'component_name.js': { html: String, err: Error? } }
  def after_response(current_response, original_response)
    current_response.keys.each do |key|
      hash = current_response[key]
      hash['html'] = '<div>hello</div>'
    end
    current_response
  end

  # NOTE: If an error happens in here, it won’t be caught.
  def on_error(error, jobs)
    puts "Oh no, error - #{error}, jobs - #{jobs}"
  end
end

Hypernova.add_plugin!(HypernovaPlugin.new)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release` to create a git tag for the version, push git
commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/airbnb/hypernova-ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
