# frozen_string_literal: true

module Polymarket
  module HttpHelpers
    # TODO: Port HTTP helpers from Python http_helpers/helpers.py

    def self.build_query_params(url, param, val)
      if url[-1] == '?'
        "#{url}#{param}=#{val}"
      else
        "#{url}&#{param}=#{val}"
      end
    end

    def self.add_query_trade_params(base_url, params = nil, next_cursor = 'MA==')
      url = base_url
      if params
        url += '?'
        url = build_query_params(url, 'market', params.market) if params.respond_to?(:market) && params.market
        url = build_query_params(url, 'asset_id', params.asset_id) if params.respond_to?(:asset_id) && params.asset_id
        url = build_query_params(url, 'after', params.after) if params.respond_to?(:after) && params.after
        url = build_query_params(url, 'before', params.before) if params.respond_to?(:before) && params.before
        url = build_query_params(url, 'maker_address', params.maker_address) if params.respond_to?(:maker_address) && params.maker_address
        url = build_query_params(url, 'id', params.id) if params.respond_to?(:id) && params.id
        url = build_query_params(url, 'next_cursor', next_cursor) if next_cursor
      end
      url
    end

    def self.add_query_open_orders_params(base_url, params = nil, next_cursor = 'MA==')
      url = base_url
      if params
        url += '?'
        url = build_query_params(url, 'market', params.market) if params.respond_to?(:market) && params.market
        url = build_query_params(url, 'asset_id', params.asset_id) if params.respond_to?(:asset_id) && params.asset_id
        url = build_query_params(url, 'id', params.id) if params.respond_to?(:id) && params.id
        url = build_query_params(url, 'next_cursor', next_cursor) if next_cursor
      end
      url
    end

    def self.drop_notifications_query_params(base_url, params = nil)
      url = base_url
      if params
        url += '?'
        url = build_query_params(url, 'ids', params.ids.join(',')) if params.respond_to?(:ids) && params.ids
      end
      url
    end

    def self.add_balance_allowance_params_to_url(base_url, params = nil)
      url = base_url
      if params
        url += '?'
        url = build_query_params(url, 'asset_type', params.asset_type.to_s) if params.respond_to?(:asset_type) && params.asset_type
        url = build_query_params(url, 'token_id', params.token_id) if params.respond_to?(:token_id) && params.token_id
        url = build_query_params(url, 'signature_type', params.signature_type) if params.respond_to?(:signature_type) && !params.signature_type.nil?
      end
      url
    end

    def self.add_order_scoring_params_to_url(base_url, params = nil)
      url = base_url
      if params
        url += '?'
        url = build_query_params(url, 'order_id', params.orderId) if params.respond_to?(:orderId) && params.orderId
      end
      url
    end

    def self.add_orders_scoring_params_to_url(base_url, params = nil)
      url = base_url
      if params
        url += '?'
        url = build_query_params(url, 'order_ids', params.orderIds.join(',')) if params.respond_to?(:orderIds) && params.orderIds
      end
      url
    end

    # Stub request helpers (get, post, delete)
    def self.get(endpoint, headers = nil, data = nil)
      # TODO: Implement if needed
      nil
    end
    def self.post(endpoint, headers = nil, data = nil)
      # TODO: Implement if needed
      nil
    end
    def self.delete(endpoint, headers = nil, data = nil)
      # TODO: Implement if needed
      nil
    end
  end
end 