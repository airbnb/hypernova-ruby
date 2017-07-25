module Hypernova::PluginHelper
  def get_view_data(name, data)
    Hypernova.plugins.reduce(data) do |data, plugin|
      if plugin.respond_to?(:get_view_data)
        plugin.get_view_data(name, data)
      else
        data
      end
    end
  end

  def prepare_request(current_request, original_request)
    Hypernova.plugins.reduce(current_request) do |req, plugin|
      if plugin.respond_to?(:prepare_request)
        plugin.prepare_request(req, original_request)
      else
        req
      end
    end
  end

  def send_request?(jobs_hash)
    Hypernova.plugins.all? do |plugin|
      if plugin.respond_to?(:send_request?)
        plugin.send_request?(jobs_hash)
      else
        true
      end
    end
  end

  def will_send_request(jobs_hash)
    Hypernova.plugins.each do |plugin|
      if plugin.respond_to?(:will_send_request)
        plugin.will_send_request(jobs_hash)
      end
    end
  end

  def after_response(current_response, original_response)
    Hypernova.plugins.reduce(current_response) do |response, plugin|
      if plugin.methods.include?(:after_response)
        plugin.after_response(response, original_response)
      else
        response
      end
    end
  end

  def on_error(error, job = nil, jobs_hash = nil)
    Hypernova.plugins.each { |plugin| plugin.on_error(error, job, jobs_hash) if plugin.respond_to?(:on_error) }
  end

  def on_success(res, jobs_hash)
    Hypernova.plugins.each do |plugin|
      plugin.on_success(res, jobs_hash) if plugin.respond_to?(:on_success)
    end
  end
end
