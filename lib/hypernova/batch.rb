require 'forwardable'

module Hypernova
  class Batch
    extend Forwardable

    attr_accessor :service
    attr_reader :jobs

    def_delegators :jobs, :empty?

    ##
    # @param service the Hypernova backend service to use for render_react_batch
    # The only requirement for the `service` object is the method render_react_batch
    # which should accept a Hash of { job_token :: Scalar => job_data :: Hash }
    # the subscript operator, to access result via tokens
    def initialize(service)
      # TODO: make hashmap instead????
      @jobs = []
      @service = service
    end

    def render(job)
      Hypernova.verify_job_shape(job)
      token = jobs.length
      jobs << job
      token.to_s
    end

    def submit!
      service.render_batch(jobs_hash)
    end

    def submit_fallback!
      service.render_batch_blank(jobs_hash)
    end

    private

    attr_reader :service

    # creates a hash with each index mapped to the value at that index
    def jobs_hash
      hash = {}
      jobs.each_with_index { |job, idx| hash[idx.to_s] = job }
      hash
    end
  end
end
