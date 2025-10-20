# frozen_string_literal: true

require 'eth'

module Polymarket
  class Signer
    attr_reader :private_key, :chain_id

    def initialize(private_key, chain_id)
      raise ArgumentError, 'private_key and chain_id are required' if private_key.nil? || chain_id.nil?
      @private_key = private_key
      @key = Eth::Key.new priv: private_key
      @chain_id = chain_id
    end

    def address
      @key.address.to_s
    end

    def get_chain_id
      @chain_id
    end

    # correct
    def sign(message_hash)
      sig = @key.sign(message_hash)  # expects 32-byte binary
      Polymarket::Signing::EIP712.prepend_zx sig
    end
    
  end
end 