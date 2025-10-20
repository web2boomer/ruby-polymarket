# frozen_string_literal: true
require 'bigdecimal'
require 'securerandom'
require_relative 'clob_config'

module Polymarket
  module OrderBuilderConstants
    BUY = 'BUY'
    SELL = 'SELL'
    BUY_SIDE = 0
    SELL_SIDE = 1
  end

  module OrderBuilderHelpers
    def self.round_down(x, sig_digits)
      (x * (10**sig_digits)).floor / (10.0**sig_digits)
    end

    def self.round_normal(x, sig_digits)
      (x * (10**sig_digits)).round / (10.0**sig_digits)
    end

    def self.round_up(x, sig_digits)
      (x * (10**sig_digits)).ceil / (10.0**sig_digits)
    end

    def self.to_token_decimals(x)
      f = (10**6) * x
      f = round_normal(f, 0) if decimal_places(f) > 0
      f.to_i
    end

    def self.decimal_places(x)
      BigDecimal(x.to_s).exponent.abs
    end

    def self.generate_salt
      # Generate a unique salt for order entropy
      SecureRandom.hex(32).to_i(16)
    end
  end  


  RoundConfig = Struct.new(:price, :size, :amount, keyword_init: true)

  ROUNDING_CONFIG = {
    '0.1'    => RoundConfig.new(price: 1, size: 2, amount: 3),
    '0.01'   => RoundConfig.new(price: 2, size: 2, amount: 4),
    '0.001'  => RoundConfig.new(price: 3, size: 2, amount: 5),
    '0.0001' => RoundConfig.new(price: 4, size: 2, amount: 6)
  }

  class OrderBuilder
    include OrderBuilderConstants
    include OrderBuilderHelpers

    def initialize(signer, sig_type: nil, funder: nil)
      @signer = signer
      @sig_type = sig_type || 'EOA'  # Default to EOA if not specified
      @funder = funder || @signer.address
    end


    def get_order_amounts(side, size, price, round_config)
      raw_price = OrderBuilderHelpers.round_normal(price, round_config[:price])

      if side == BUY
        raw_taker = OrderBuilderHelpers.round_down(size, round_config[:size])
        raw_maker = adjust_precision(raw_taker * raw_price, round_config[:amount])

        [BUY_SIDE, OrderBuilderHelpers.to_token_decimals(raw_maker), OrderBuilderHelpers.to_token_decimals(raw_taker)]
      elsif side == SELL
        raw_maker = OrderBuilderHelpers.round_down(size, round_config[:size])
        raw_taker = adjust_precision(raw_maker * raw_price, round_config[:amount])

        [SELL_SIDE, OrderBuilderHelpers.to_token_decimals(raw_maker), OrderBuilderHelpers.to_token_decimals(raw_taker)]
      else
        raise ArgumentError, "order_args.side must be '#{BUY}' or '#{SELL}'"
      end
    end
    
    # Helper method to enforce decimal precision limits
    def adjust_precision(value, max_decimals)
      if OrderBuilderHelpers.decimal_places(value) > max_decimals
        value = OrderBuilderHelpers.round_up(value, max_decimals + 4)
        if OrderBuilderHelpers.decimal_places(value) > max_decimals
          value = OrderBuilderHelpers.round_down(value, max_decimals)
        end
      end
      value
    end


    def get_market_order_amounts(side, amount, price, round_config)
      # get from above method 
    end

    def create_order(order_args, options)
      tick_size = options[:tick_size]
      neg_risk = options[:neg_risk]
      round_config = ROUNDING_CONFIG[tick_size]
      puts  "[DEBUG] round_config in create_order: #{round_config.inspect}" 
      side, maker_amount, taker_amount = get_order_amounts(
        order_args.side,
        order_args.size,
        order_args.price,
        round_config
      )

      puts  "[DEBUG] side: #{side}" 
      puts  "[DEBUG] maker_amount: #{maker_amount}" 
      puts  "[DEBUG] taker_amount: #{taker_amount}" 
      puts  "[DEBUG] round_config: #{round_config.inspect}" 

      # Generate salt for order uniqueness
      salt = OrderBuilderHelpers.generate_salt
      puts  "[DEBUG] salt: #{salt}" 

      # Get contract config for domain (for verifyingContract)
      contract_config = Polymarket::CLOBConfig.get_contract_config(@signer.get_chain_id , neg_risk)
      puts  "[DEBUG] contract_config: #{contract_config.inspect}" 
      puts "[DEBUG] exchange: #{contract_config.exchange}"

      order_data = Polymarket::Signing::OrderStruct.new(
        maker: @funder,
        taker: order_args.taker,
        token_id: order_args.token_id.to_i,
        maker_amount: maker_amount.to_i,
        taker_amount: taker_amount.to_i,
        side: side,
        fee_rate_bps: order_args.fee_rate_bps.to_i,
        nonce: order_args.nonce.to_i,
        signer: @signer.address,
        expiration: order_args.expiration.to_i,
        signature_type: @sig_type.to_i,
        salt: salt.to_i
      )
      puts  "[DEBUG] order_data: #{order_data.inspect}" 

      domain = Polymarket::Signing::EIP712.get_clob_auth_domain(@signer.get_chain_id, contract_config)
      puts "[DEBUG] domain: #{domain.inspect}"
      signable_data = order_data.signable_bytes(domain)
      puts "Digest to sign: 0x" + signable_data.unpack1("H*")
      
      order_data.signature = @signer.sign(signable_data)
      puts "Signature" + order_data.signature 

      puts  "[DEBUG] signed order: #{order_data.inspect}" 
      order_data
    end

    def create_market_order(order_args, options)
      # stub to implement
    end

  end
end 