# frozen_string_literal: true

module Polymarket
  module Exceptions
    # TODO: Port exceptions from Python exceptions.py
  end

  class PolymarketException < StandardError
    attr_reader :msg
    def initialize(msg)
      @msg = msg
      super(msg)
    end
  end

  class PolymarketApiException < PolymarketException
    attr_reader :status_code, :error_msg
    def initialize(resp = nil, error_msg = nil)
      if resp
        @status_code = resp.respond_to?(:code) ? resp.code : nil
        @error_msg = resp.respond_to?(:body) ? resp.body : nil
      end
      if error_msg
        @error_msg = error_msg
        @status_code = nil
      end
      super(@error_msg)
    end

    def to_s
      "PolymarketApiException[status_code=#{@status_code}, error_message=#{@error_msg}]"
    end
  end
end 