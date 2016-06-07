require "spec_helper"

describe Hypernova do
  describe ".configure" do
    it "configures Hypernova" do
      described_class.configure do |config|
        config.http_adapter = "http_adapter"
      end
      expect(described_class.configuration.http_adapter).to eq("http_adapter")
    end
  end

  describe :render_token do
    it "returns the same render_token for the same batch_token" do
      t1 = Hypernova.render_token(0)
      t2 = Hypernova.render_token(0)
      expect(t1).to eq(t2)
    end

    it "returns different render_tokens for different batch tokens" do
      t1 = Hypernova.render_token('hello')
      t2 = Hypernova.render_token('goodbye')
      expect(t1).not_to eq(t2)
    end

    it "matches the token regex" do
      t = Hypernova.render_token(0)
      expect(t).to match(Hypernova::RENDER_TOKEN_REGEX)
    end
  end

  describe :replace_tokens_with_result do
    # pretty much test everything all at once
    it "replaces render_tokens with batch results" do
      batch_result = {0 => 'this is zero', 'france' => 'this is one'}
      render_token_to_batch_token = {
        Hypernova.render_token(0) => 0,
        Hypernova.render_token('france') => 'france',
      }
      body = Helpers.template(Hypernova.render_token(0), Hypernova.render_token('france'))
      new_body = Hypernova.replace_tokens_with_result(body,
                                                         render_token_to_batch_token,
                                                         batch_result)
      expect(new_body).to eq(Helpers.template(batch_result[0], batch_result['france']))
    end

    it "leaves unknown render_tokens in place" do
      batch_result = {0 => 'this is zero'}
      token_mapping = {Hypernova.render_token(0) => 0}
      body = Helpers.template(Hypernova.render_token(0), Hypernova.render_token(1))
      new_body = Hypernova.replace_tokens_with_result(body, token_mapping, batch_result)
      expect(new_body).to eq(Helpers.template(batch_result[0], Hypernova.render_token(1)))
    end
  end

  describe :verify_job_shape do
    it "throws if :name is undefined" do
      expect { Hypernova.verify_job_shape({:data => true}) }.
        to raise_error(Hypernova::BadJobError)
    end
    it "throws if :data is undefined" do
      expect { Hypernova.verify_job_shape({:name => true}) }.
        to raise_error(Hypernova::BadJobError)
    end

    it "is happy if all three defined" do
      expect { Hypernova.verify_job_shape({:name => true, :data => true}) }.
        not_to raise_error
    end
  end
end
