# frozen_string_literal: true

module Polymarket
  module Constants
    L0 = 0
    L1 = 1
    L2 = 2

    CREDENTIAL_CREATION_WARNING = """🚨🚨🚨\nYour credentials CANNOT be recovered after they've been created.\nBe sure to store them safely!\n🚨🚨🚨"""

    L1_AUTH_UNAVAILABLE = 'A private key is needed to interact with this endpoint!'
    L2_AUTH_UNAVAILABLE = 'API Credentials are needed to interact with this endpoint!'
    ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'
    AMOY = 80002
    POLYGON = 137
    END_CURSOR = 'LTE='
    
    # Default API hosts
    DEFAULT_CLOB_HOST = 'https://clob.polymarket.com'
    DEFAULT_GAMMA_HOST = 'https://gamma-api.polymarket.com'
    DEFAULT_DATA_HOST = 'https://data-api.polymarket.com'
  end


end 