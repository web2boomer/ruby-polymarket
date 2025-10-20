# frozen_string_literal: true

require_relative "polymarket/version"
require_relative "polymarket/client"
require_relative "polymarket/clob_types"
require_relative "polymarket/config"
require_relative "polymarket/constants"
require_relative "polymarket/endpoints"
require_relative "polymarket/exceptions"
require_relative "polymarket/headers"
require_relative "polymarket/http_helpers"
require_relative "polymarket/order_builder"
require_relative "polymarket/signer"
require_relative "polymarket/signing"
require_relative "polymarket/utilities"

module Polymarket
  class Error < StandardError; end
  # Your code goes here...
end
