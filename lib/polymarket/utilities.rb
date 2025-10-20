# frozen_string_literal: true
require 'digest/sha1'
require 'json'

module Polymarket
  module Utilities
    def self.parse_raw_orderbook_summary(raw_obs)
      bids = raw_obs["bids"].map { |bid| Polymarket::OrderSummary.new(size: bid["size"], price: bid["price"]) }
      asks = raw_obs["asks"].map { |ask| Polymarket::OrderSummary.new(size: ask["size"], price: ask["price"]) }
      Polymarket::OrderBookSummary.new(
        market: raw_obs["market"],
        asset_id: raw_obs["asset_id"],
        timestamp: raw_obs["timestamp"],
        bids: bids,
        asks: asks,
        hash: raw_obs["hash"]
      )
    end

    def self.generate_orderbook_summary_hash(orderbook)
      orderbook.hash = ""
      hash = Digest::SHA1.hexdigest(orderbook.to_json)
      orderbook.hash = hash
      hash
    end

    def self.camelize(str)
      str.to_s.gsub(/_([a-z])/) { $1.upcase }
    end

    def self.order_to_json(order, owner, order_type)
      order_hash = order.to_h

      camel_order = order_hash.each_with_object({}) do |(k, v), h|
        camel_key =
          case k.to_s
          when 'token_id' then 'tokenId'
          when 'signature_type' then 'signatureType'
          else camelize(k)
          end

        h[camel_key] =
          case camel_key
          when 'side', 'signatureType'
            v.to_i
          when 'signature'
            v
          else
            v.to_s
          end
      end

      { order: camel_order, owner: owner, orderType: order_type }
    end

    def self.is_tick_size_smaller(a, b)
      a.to_f < b.to_f
    end

    def self.price_valid(price, tick_size)
      price >= tick_size.to_f && price <= 1 - tick_size.to_f
    end
  end
end 