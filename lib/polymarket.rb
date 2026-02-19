# frozen_string_literal: true

require_relative "polymarket/version"
require_relative "polymarket/clob_client"
require_relative "polymarket/gamma_client"
require_relative "polymarket/data_client"
require_relative "polymarket/ctf_client"
require_relative "polymarket/clob_types"
require_relative "polymarket/constants"
require_relative "polymarket/clob_endpoints"
require_relative "polymarket/gamma_endpoints"
require_relative "polymarket/data_endpoints"
require_relative "polymarket/exceptions"
require_relative "polymarket/headers"
require_relative "polymarket/http_helpers"
require_relative "polymarket/order_builder"
require_relative "polymarket/signer"
require_relative "polymarket/signing"
require_relative "polymarket/utilities"

module Polymarket
  class Error < StandardError; end
  
  # Convenience methods for creating clients
  def self.clob_client(**options)
    CLOBClient.new(**options)
  end
  
  def self.gamma_client(**options)
    GammaClient.new(**options)
  end
  
  def self.data_client(**options)
    DataClient.new(**options)
  end
  
  def self.ctf_client(**options)
    CTFClient.new(**options)
  end
end
