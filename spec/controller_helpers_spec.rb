require 'spec_helper'

describe Hypernova::ControllerHelpers do
  let :controller do
    Helpers::Controller.new
  end

  let :full_controller do
    ctlr = Helpers::ControllerWithService.new
    ctlr.send(:hypernova_batch_before)
    ctlr
  end

  let :request_data do
    {
      :test => 1,
      :what => 'what?'
    }
  end

  after(:each) do
    Hypernova.instance_variable_set(:@plugins, nil)
  end

  describe "hypernova_batch_render" do
    it 'throws if has not run hypernova_batch_before' do
      expect { controller.hypernova_batch_render(Helpers.args_1) }.
        to raise_error(Hypernova::NilBatchError)
    end

    it 'returns a render_token' do
      t = full_controller.hypernova_batch_render(Helpers.args_1)
      expect(t).to match(Hypernova::RENDER_TOKEN_REGEX)
    end
  end

  describe "hypernova_batch_after" do
    it 'throws if has not run hypernova_batch_before' do
      expect { controller.send(:hypernova_batch_after) }.to raise_error(Hypernova::NilBatchError)
    end

    # this test relies on hypernova_service being the token mirror service,
    # and on the batch class implementing sequential, non-random tokens (the 0, 1 part)
    it 'correctly modifies response.body' do
      t1 = full_controller.hypernova_batch_render(Helpers.args_1)
      t2 = full_controller.hypernova_batch_render(Helpers.args_1)
      body = Helpers.template(t1, t2)
      response = full_controller.make_response(body)

      expect(response).to receive(:body=) do |new_body|
        # this is the brittle part
        expect(new_body).to eq(Helpers.template(0, 1))
      end

      full_controller.define_singleton_method :response do
        response
      end

      full_controller.send(:hypernova_batch_after)
    end
  end

  describe "hypernova_render_support" do
    it 'yields to a block' do
      something = 1
      full_controller.hypernova_render_support do
        full_controller.make_response('undefined is not a function')
        something = 2
      end
      expect(something).to eq(2)
    end

    it 'calls hypernova_batch_before' do
      expect(full_controller).to receive(:hypernova_batch_before)
      full_controller.hypernova_render_support do
        full_controller.make_response('lel')
      end
    end

    it 'calls hypernova_batch_after after the block' do
      full_controller.hypernova_render_support do
        full_controller.make_response('hello world')
        expect(full_controller).to receive(:hypernova_batch_after)
      end
    end

    context "when an error is raised" do
      it "calls on_error and submit_fallback! on @hypernova_batch" do
        class TestClass
          include Hypernova::ControllerHelpers
        end

        class TestResponse
          attr_accessor :body

          def initialize
            @body = ""
          end
        end

        test = TestClass.new
        batch = Hypernova::Batch.new(test.hypernova_service)
        error = StandardError.new
        response = TestResponse.new

        batch.render({ name: "mordor.js", data: {} })

        allow(Hypernova::Batch).to receive(:new).with(test.hypernova_service).and_return(batch)
        allow(test).to receive(:will_send_request).and_raise(error)
        allow(test).to receive(:response).and_return(response)

        expect(test).to receive(:on_error).with(error, nil, hash_including('mordor.js'))
        expect(batch).to receive(:submit_fallback!)

        test.hypernova_render_support {}
      end
    end

    context "when a response comes back" do
      it "calls on_success" do
        class TestClass
          include Hypernova::ControllerHelpers
        end

        class TestResponse
          attr_accessor :body

          def initialize
            @body = ""
          end
        end

        Hypernova.configure do |config|
          config.host = "mordor.com"
          config.port = 1337
        end

        stub_request(:post, "http://mordor.com:1337/batch").
          with(:body => "{\"0\":{\"name\":\"mordor.js\",\"data\":{}}}").
          to_return(:status => 200, :body => '{}', :headers => {})

        test = TestClass.new
        batch = Hypernova::Batch.new(test.hypernova_service)
        response = TestResponse.new
        jobs = { name: "mordor.js", data: {} }

        batch.render(jobs)

        allow(Hypernova::Batch).to receive(:new).with(test.hypernova_service).and_return(batch)
        allow(test).to receive(:response).and_return(response)

        expect(test).to receive(:on_success).with({}, { "mordor.js" => jobs })

        test.hypernova_render_support {}
      end
    end

  end

  describe "#hypernova_service" do
    it "returns an instance of Hypernova::RequestService" do
      class TestClass
        include Hypernova::ControllerHelpers
      end

      allow(Hypernova::RequestService).to receive(:new).and_call_original
      expect(Hypernova::RequestService).to receive(:new)
      expect(TestClass.new.hypernova_service.class).to eq(Hypernova::RequestService)
    end
  end

  describe "#render_react_component" do
    let(:data) { { energy: 100 } }
    let(:name) { "laser.js" }
    let(:new_data) { data.merge({ power: 150 }) }
    let(:job) { { data: new_data, name: name } }
    let(:result) { double("result") }
    let(:test) do
      class TestClass
        include Hypernova::ControllerHelpers
      end
      TestClass.new
    end

    context "when no error is raised" do
      it "calls get_view_data and hypernova_batch_render" do
        allow(test).to receive(:get_view_data).with(name, data).and_return(new_data)
        allow(test).to receive(:hypernova_batch_render).with(job).and_return(result)

        expect(test.render_react_component(name, data)).to equal(result)
      end
    end

    context "when an error is raised" do
      it "calls on_error and hypernova_batch_render" do
        error = StandardError.new

        allow(test).to receive(:get_view_data).with(name, data).and_raise(error)
        allow(test).to receive(:hypernova_batch_render).
          with({
            data: data,
            name: name,
          }).
          and_return(result)

        expect(test).to receive(:on_error).with(error)
        expect(test.render_react_component(name, data)).to equal(result)
      end
    end
  end

  describe 'plugin lifecycle' do
    describe 'get_view_data plugins' do
      class GetComponentPropsPlugin
        def get_view_data(component, props)
          props[:test] = props[:test] + 1
          props
        end
      end

      it 'gets called on every plugin that has it' do
        x = GetComponentPropsPlugin.new
        y = GetComponentPropsPlugin.new
        Hypernova.add_plugin!(x)
        Hypernova.add_plugin!(y)
        expect(x).to receive(:get_view_data).and_call_original
        expect(y).to receive(:get_view_data).and_call_original
        full_controller.render_react_component('test', request_data)
      end

      it 'mutates the data field' do
        Hypernova.add_plugin!(GetComponentPropsPlugin.new)
        expect(full_controller).to receive(:hypernova_batch_render).with({
          :name=> 'test',
          :data => {
            :test => 2,
            :what => 'what?'
          }
        })
        full_controller.render_react_component('test', request_data)
      end
    end

    describe 'send_request?' do
      class ShouldSendRequestFalsePlugin
        def send_request?(request)
          false
        end
      end
      class ShouldSendRequestTruePlugin
        def send_request?(request)
          true
        end
      end

      it 'should fire before making a request' do
        plugin = ShouldSendRequestTruePlugin.new
        Hypernova.add_plugin!(plugin)
        expect(plugin).to receive(:send_request?).ordered.and_call_original
        expect(full_controller.hypernova_service).to receive(:render_batch).ordered
        full_controller.render_react_component('test', request_data)
        full_controller.make_response('hello world')
        full_controller.send(:hypernova_batch_after)
      end

      it 'should prevent requests from firing if it returns false' do
        plugin = ShouldSendRequestFalsePlugin.new
        Hypernova.add_plugin!(plugin)
        expect(plugin).to receive(:send_request?).ordered.and_call_original
        expect(full_controller.hypernova_service).to receive(:render_batch_blank).ordered
        full_controller.render_react_component('test', request_data)
        full_controller.make_response('hello world')
        full_controller.send(:hypernova_batch_after)
      end

      it 'should prevent requests from firing if ANY return false' do
        plugin1 = ShouldSendRequestFalsePlugin.new
        plugin2 = ShouldSendRequestTruePlugin.new
        Hypernova.add_plugin!(plugin1)
        Hypernova.add_plugin!(plugin2)
        expect(plugin1).to receive(:send_request?).ordered.and_call_original
        expect(plugin2).to_not receive(:send_request?).ordered.and_call_original
        expect(full_controller.send_request?({})).to be false
      end
    end

    describe "prepare_request plugins" do
      class PrepareRequestPlugin
        def prepare_request(current_request, _)
          current_request['test'][:data][:what] = 'who?'
        end
      end

      it 'should be able to alter the request data' do
        plugin = PrepareRequestPlugin.new
        Hypernova.add_plugin!(plugin)
        request = {
          'test' => {
            :name => 'test',
            :data => request_data,
          },
        }
        expect(plugin).to receive(:prepare_request).with(request, request).and_call_original
        expect(full_controller.hypernova_service).to receive(:render_batch).with({
          '0' => {
            :name => 'test',
            :data => {
              :test => 1,
              :what => 'who?'
            }
          }
        })
        full_controller.render_react_component('test', request_data)
        full_controller.make_response('hello world')
        full_controller.send(:hypernova_batch_after)
      end
    end

    describe 'will_send_request plugin' do
      class WillSendRequestPlugin
        def will_send_request(_)
        end
      end
      it 'is called before rendering' do
        x = WillSendRequestPlugin.new
        Hypernova.add_plugin!(x)
        expect(x).to receive(:will_send_request).ordered
        expect(full_controller.hypernova_service).to receive(:render_batch).ordered
        full_controller.render_react_component('test', request_data)
        full_controller.make_response('hello world')
        full_controller.send(:hypernova_batch_after)
      end
    end

    describe 'plugin lifecycle order' do
      it 'should run the lifecycle hooks in order' do
        class AllLifecycleHooks
          def get_view_data(component, props)
            props
          end
          def prepare_request(req, _)
            req
          end
          def send_request?(data)
            true
          end
          def will_send_request(req)
          end
        end
        x = AllLifecycleHooks.new
        Hypernova.add_plugin!(x)
        expect(x).to receive(:get_view_data).ordered.and_call_original
        expect(x).to receive(:prepare_request).ordered.and_call_original
        expect(x).to receive(:send_request?).ordered.and_call_original
        expect(x).to receive(:will_send_request).ordered.and_call_original
        full_controller.render_react_component('test', request_data)
        full_controller.make_response('hello world')
        full_controller.send(:hypernova_batch_after)
      end
    end
  end
end
