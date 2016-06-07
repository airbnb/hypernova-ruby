require 'spec_helper'

RSpec.describe Hypernova::Batch do
  let :service do
    Helpers::TokenIdentityService.new
  end
  let :batch do
    Hypernova::Batch.new(service)
  end

  describe :render do
    it "returns a token" do
      expect(batch.render(Helpers.args_1)).not_to be_nil
    end

    it "returns a new token for each call" do
      token1 = batch.render(Helpers.args_1)
      token2 = batch.render(Helpers.args_1)

      expect(token1).to_not equal(token2)
    end

    it "the token is a string" do
      expect(batch.render(Helpers.args_1)).to be_instance_of(String)
    end
  end

  describe :submit! do
    it "calls the service's render_batch method with a hash of jobs" do
      expect(service).to receive(:render_batch).with({})
      batcher = Hypernova::Batch.new(service)
      batcher.submit!
    end

    it "calls the service with the right number of jobs" do
      expect(service).to receive(:render_batch) do |jobs|
        expect(jobs.to_a.length).to equal(3)
      end
      batcher = Hypernova::Batch.new(service)
      batcher.render(Helpers.args_1)
      batcher.render(Helpers.args_1)
      batcher.render(Helpers.args_1)
      batcher.submit!
    end

    it "creates a jobs hash with String keys" do
      expect(service).to receive(:render_batch) do |jobs|
        expect(jobs.keys.first).to be_a(String)
      end
      batcher = Hypernova::Batch.new(service)
      batcher.render(Helpers.args_1)
      batcher.submit!
    end

    it "returns a results object" do
      results = batch.submit!
      expect(results).to_not be(nil)
    end

    it "returns a results object that responds to []" do
      results = batch.submit!
      expect(results).to respond_to(:[])
    end
  end

  describe :empty? do
    let(:batcher) { Hypernova::Batch.new(service) }

    it 'returns false when there are jobs' do
      batcher.render(Helpers.args_1)
      expect(batcher).not_to be_empty
    end

    it 'returns true when there are no jobs' do
      expect(batcher).to be_empty
    end
  end

  # not really sure how to test the rest of the stuff yet since I'm bad at TDD
end
