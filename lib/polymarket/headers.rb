# frozen_string_literal: true
require 'time'
require_relative 'signing'

module Polymarket
  module Headers
    POLY_ADDRESS = 'POLY_ADDRESS'
    POLY_SIGNATURE = 'POLY_SIGNATURE'
    POLY_TIMESTAMP = 'POLY_TIMESTAMP'
    POLY_NONCE = 'POLY_NONCE'
    POLY_API_KEY = 'POLY_API_KEY'
    POLY_PASSPHRASE = 'POLY_PASSPHRASE'

    def self.create_level_1_headers(signer, nonce = nil)
      timestamp = Time.now.to_i
      signature = Polymarket::Signing::EIP712.sign_clob_auth_message(signer, timestamp, nonce)
      {
        POLY_ADDRESS => signer.address,
        POLY_SIGNATURE => signature,
        POLY_TIMESTAMP => timestamp.to_s,
        POLY_NONCE => nonce.to_s
      }
    end

    def self.create_level_2_headers(signer, creds, request_args)
      timestamp = Time.now.to_i
      hmac_sig = Polymarket::Signing::HMAC.build_hmac_signature(
        creds.api_secret,
        timestamp,
        request_args.method,
        request_args.request_path,
        request_args.body
      )
      {
        POLY_ADDRESS => signer.address,
        POLY_SIGNATURE => hmac_sig,
        POLY_TIMESTAMP => timestamp.to_s,
        POLY_API_KEY => creds.api_key,
        POLY_PASSPHRASE => creds.api_passphrase
      }
    end
  end
end 