require "spec_helper"
require "hypernova/plugin_helper"

describe Hypernova::PluginHelper do
  class TestClass
    include Hypernova::PluginHelper
  end

  describe "#get_view_data" do
    it "reduces the properties" do
      class Plugin
        def get_view_data(name, data)
          data.merge({
            blade: "sharp",
            name: name,
          })
        end
      end

      Hypernova.add_plugin!(Plugin.new)

      expect(TestClass.new.get_view_data("shield.js", { vibranium: true })).
        to include({
          blade: "sharp",
          name: "shield.js",
          vibranium: true,
        })
    end
  end

  describe "#on_error" do
    it "calls on_error for each plugin" do
      class Plugin
        def on_error(error, job, jobs_hash)
        end
      end

      plugin = Plugin.new
      Hypernova.add_plugin!(plugin)

      error = double("error")
      job = double("job")
      jobs_hash = double("jobs")

      expect(plugin).to receive(:on_error).with(error, job, jobs_hash)
      TestClass.new.on_error(error, job, jobs_hash)
    end
  end

  describe "#on_success" do
    it "calls on_success for each plugin" do
      class Plugin
        def on_success(res, jobs)
        end
      end

      plugin = Plugin.new
      Hypernova.add_plugin!(plugin)

      res = double("res")
      jobs = double("jobs")

      expect(plugin).to receive(:on_success).with(res, jobs)
      TestClass.new.on_success(res, jobs)
    end
  end
end
