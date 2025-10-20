# frozen_string_literal: true
require 'net/http'
require 'uri'
require_relative 'clob_types'
require 'json'

module Polymarket
  class Client
    attr_reader :host, :chain_id, :signer, :creds, :mode, :builder

    def initialize(host:, chain_id: nil, key: nil, creds: nil, signature_type: nil, funder: nil)
      # Remove trailing slash from host
      @host = host.end_with?('/') ? host[0..-2] : host
      @chain_id = chain_id
      @signer = key ? Signer.new(key, chain_id) : nil
      @creds = creds
      @mode = get_client_mode
      @order_builder = @signer ? OrderBuilder.new(@signer, sig_type: signature_type, funder: funder) : nil
      # Local cache
      @tick_sizes = {}
      @neg_risk = {}
    end

    def get_address
      @signer ? @signer.address : nil
    end

    def get_ok
      uri = URI.parse("#{@host}")
      Net::HTTP.get_response(uri)
    end

    def get_server_time
      uri = URI.parse("#{@host}#{Endpoints::TIME}")
      Net::HTTP.get_response(uri)
    end

    def create_api_key(nonce: nil)
      endpoint = "#{@host}#{Endpoints::CREATE_API_KEY}"
      headers = Polymarket::Headers.create_level_1_headers(@signer, nonce)
      uri = URI.parse(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        creds_raw = JSON.parse(response.body)
        Polymarket::ApiCreds.new(
          api_key: creds_raw["apiKey"],
          api_secret: creds_raw["secret"],
          api_passphrase: creds_raw["passphrase"]
        )
      else
        raise "Couldn't create CLOB creds (HTTP #{response.code}): #{response.body}"
        nil
      end
    end

    def derive_api_key(nonce: nil)
      # TODO: Implement assert_level_1_auth
      endpoint = "#{@host}#{Endpoints::DERIVE_API_KEY}"
      headers = Polymarket::Headers.create_level_1_headers(@signer, nonce)
      uri = URI.parse(endpoint)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        creds_raw = JSON.parse(response.body)
        Polymarket::ApiCreds.new(
          api_key: creds_raw["apiKey"],
          api_secret: creds_raw["secret"],
          api_passphrase: creds_raw["passphrase"]
        )
      else
        raise "Couldn't derive CLOB creds: #{response.body}"
        nil
      end
    end

    def create_or_derive_api_creds(nonce: nil)
      begin
        create_api_key(nonce: nonce)
      rescue StandardError
        derive_api_key(nonce: nonce)
      end
    end

    def set_api_creds(creds)
      @creds = creds
      @mode = get_client_mode
    end

    def get_api_keys
      # TODO: Implement assert_level_2_auth
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: Endpoints::GET_API_KEYS)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::GET_API_KEYS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get API keys: #{response.body}"
        nil
      end
    end

    def get_closed_only_mode
      # TODO: Implement assert_level_2_auth
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: Endpoints::CLOSED_ONLY)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::CLOSED_ONLY}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get closed only mode: #{response.body}"
        nil
      end
    end

    def delete_api_key
      # TODO: Implement assert_level_2_auth
      request_args = Polymarket::RequestArgs.new(method: 'DELETE', request_path: Endpoints::DELETE_API_KEY)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::DELETE_API_KEY}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Delete.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't delete API key: #{response.body}"
        nil
      end
    end

    def get_midpoint(token_id)
      uri = URI.parse("#{@host}#{Endpoints::MID_POINT}?token_id=#{token_id}")
      Net::HTTP.get_response(uri)
    end

    def get_midpoints(params)
      uri = URI.parse("#{@host}#{Endpoints::MID_POINTS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
      body = params.map { |param| { token_id: param.token_id } }
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get midpoints: #{response.body}"
        nil
      end
    end

    def get_price(token_id, side)
      uri = URI.parse("#{@host}#{Endpoints::PRICE}?token_id=#{token_id}&side=#{side}")
      Net::HTTP.get_response(uri)
    end

    def get_prices(params)
      uri = URI.parse("#{@host}#{Endpoints::GET_PRICES}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
      body = params.map { |param| { token_id: param.token_id, side: param.side } }
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get prices: #{response.body}"
        nil
      end
    end

    def get_spread(token_id)
      uri = URI.parse("#{@host}#{Endpoints::GET_SPREAD}?token_id=#{token_id}")
      Net::HTTP.get_response(uri)
    end

    def get_spreads(params)
      uri = URI.parse("#{@host}#{Endpoints::GET_SPREADS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
      body = params.map { |param| { token_id: param.token_id } }
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get spreads: #{response.body}"
        nil
      end
    end

    def get_tick_size(token_id)
      return @tick_sizes[token_id] if @tick_sizes.key?(token_id)
      uri = URI.parse("#{@host}#{Endpoints::GET_TICK_SIZE}?token_id=#{token_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        result = JSON.parse(response.body)
        @tick_sizes[token_id] = result["minimum_tick_size"].to_s
        @tick_sizes[token_id]
      else
        raise "Couldn't get tick size: #{response.body}"
        nil
      end
    end

    def get_neg_risk(token_id)
      return @neg_risk[token_id] if @neg_risk.key?(token_id)
      uri = URI.parse("#{@host}#{Endpoints::GET_NEG_RISK}?token_id=#{token_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        result = JSON.parse(response.body)
        @neg_risk[token_id] = result["neg_risk"]
        result["neg_risk"]
      else
        raise "Couldn't get neg risk: #{response.body}"
        nil
      end
    end

    def get_orders(params = nil, next_cursor = 'MA==')
      # TODO: Implement assert_level_2_auth and cursor-based pagination
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: Endpoints::ORDERS)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::ORDERS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get orders: #{response.body}"
        nil
      end
    end

    def get_order_book(token_id)
      uri = URI.parse("#{@host}#{Endpoints::GET_ORDER_BOOK}?token_id=#{token_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get order book: #{response.body}"
        nil
      end
    end

    def get_order_books(params)
      uri = URI.parse("#{@host}#{Endpoints::GET_ORDER_BOOKS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
      body = params.map { |param| { token_id: param.token_id } }
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get order books: #{response.body}"
        nil
      end
    end

    def get_order(order_id)
      # TODO: Implement assert_level_2_auth
      endpoint = "#{Endpoints::GET_ORDER}#{order_id}"
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: endpoint)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{endpoint}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get order: #{response.body}"
        nil
      end
    end

    def get_trades(params = nil, next_cursor = 'MA==')
      # TODO: Implement assert_level_2_auth and cursor-based pagination
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: Endpoints::TRADES)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::TRADES}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get trades: #{response.body}"
        nil
      end
    end

    def get_last_trade_price(token_id)
      uri = URI.parse("#{@host}#{Endpoints::GET_LAST_TRADE_PRICE}?token_id=#{token_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get last trade price: #{response.body}"
        nil
      end
    end

    def get_last_trades_prices(params)
      uri = URI.parse("#{@host}#{Endpoints::GET_LAST_TRADES_PRICES}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
      body = params.map { |param| { token_id: param.token_id } }
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get last trades prices: #{response.body}"
        nil
      end
    end

    def create_order(order_args, options = nil)
      assert_level_1_auth
      
      tick_size = get_tick_size(order_args.token_id)
      
      # Validate price with tick_size
      unless Polymarket::Utilities.price_valid(order_args.price, tick_size)
        raise ArgumentError, "Price #{order_args.price} is not valid for tick size #{tick_size}"
      end
      
      neg_risk = options&.neg_risk || get_neg_risk(order_args.token_id)

      # Create order using builder
      @order_builder.create_order(order_args, { tick_size: tick_size, neg_risk: neg_risk })
    end

    def create_market_order(order_args, options = nil)
      assert_level_1_auth
      
      tick_size = get_tick_size(order_args.token_id)
      
      # Calculate price if not present
      if order_args.price.nil? || order_args.price == 0
        # Get current market price based on side
        price_response = get_price(order_args.token_id, order_args.side)
        if price_response.is_a?(Net::HTTPSuccess)
          price_data = JSON.parse(price_response.body)
          order_args = order_args.dup
          order_args.price = price_data['price'].to_f
        else
          raise "Couldn't get market price for token #{order_args.token_id}"
        end
      end
      
      neg_risk = options&.neg_risk || get_neg_risk(order_args.token_id)
      
      # Create market order using builder
      @order_builder.create_market_order(order_args, { tick_size: tick_size, neg_risk: neg_risk })
    end

    def post_orders(args)
      # stub
    end

    def post_order(order, order_type = Polymarket::OrderType::GTC)
      assert_level_2_auth
      
      # Serialize order using order_to_json utility
      # Ensure order_type is a string (if it's a constant or symbol)
      body_hash = Polymarket::Utilities.order_to_json(order, @creds.api_key, order_type.to_s)
      body_json = body_hash.to_json
      
      request_args = Polymarket::RequestArgs.new(method: 'POST', request_path: Endpoints::POST_ORDER, body: body_json)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
        .merge(
          'Content-Type' => 'application/json',
          'user-agent'   => 'polymarket/1.0'
        )
      uri = URI.join(@host, Endpoints::POST_ORDER)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body_json
      response = http.request(request)
      # Debug: log full request
      puts  "POST #{uri}" 
      puts  "Headers: #{request.each_header.to_h}" 
      puts  "Body: #{request.body}" 
      
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        puts "Response code: #{response.code}"
        # puts "Response body: #{response.body}"
        raise "Couldn't post order: #{response.body}"
        nil
      end
    end

    def create_and_post_order(order_args, options = nil)
      ord = create_order(order_args, options)
      post_order(ord)
    end

    def cancel(order_id)
      # TODO: Implement assert_level_2_auth
      body = { orderID: order_id }
      request_args = Polymarket::RequestArgs.new(method: 'DELETE', request_path:  Endpoints::CANCEL, body: body)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::CANCEL}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Delete.new(uri.request_uri, headers.merge('Content-Type' => 'application/json'))
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't cancel order: #{response.body}"
        nil
      end
    end

    def cancel_orders(order_ids)
      # TODO: Implement assert_level_2_auth
      body = order_ids
      request_args = Polymarket::RequestArgs.new(method: 'DELETE', request_path: Endpoints::CANCEL_ORDERS, body: body)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::CANCEL_ORDERS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Delete.new(uri.request_uri, headers.merge('Content-Type' => 'application/json'))
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't cancel orders: #{response.body}"
        nil
      end
    end

    def cancel_all
      # TODO: Implement assert_level_2_auth
      request_args = Polymarket::RequestArgs.new(method: 'DELETE', request_path: Endpoints::CANCEL_ALL)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::CANCEL_ALL}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Delete.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't cancel all orders: #{response.body}"
        nil
      end
    end

    def cancel_market_orders(market: '', asset_id: '')
      # TODO: Implement assert_level_2_auth
      body = { market: market, asset_id: asset_id }
      request_args = Polymarket::RequestArgs.new(method: 'DELETE', request_path: Endpoints::CANCEL_MARKET_ORDERS, body: body)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::CANCEL_MARKET_ORDERS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Delete.new(uri.request_uri, headers.merge('Content-Type' => 'application/json'))
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't cancel market orders: #{response.body}"
        nil
      end
    end

    def get_notifications
      # TODO: Implement assert_level_2_auth
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: Endpoints::GET_NOTIFICATIONS)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::GET_NOTIFICATIONS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get notifications: #{response.body}"
        nil
      end
    end

    def drop_notifications(params = nil)
      # TODO: Implement assert_level_2_auth and drop_notifications_query_params
      request_args = Polymarket::RequestArgs.new(method: 'DELETE', request_path: Endpoints::DROP_NOTIFICATIONS)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::DROP_NOTIFICATIONS}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Delete.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't drop notifications: #{response.body}"
        nil
      end
    end

    def get_balance_allowance(params = nil)
      # TODO: Implement assert_level_2_auth and add_balance_allowance_params_to_url
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: Endpoints::GET_BALANCE_ALLOWANCE)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::GET_BALANCE_ALLOWANCE}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get balance allowance: #{response.body}"
        nil
      end
    end

    def update_balance_allowance(params = nil)
      # TODO: Implement assert_level_2_auth and add_balance_allowance_params_to_url
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: Endpoints::UPDATE_BALANCE_ALLOWANCE)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::UPDATE_BALANCE_ALLOWANCE}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't update balance allowance: #{response.body}"
        nil
      end
    end

    def is_order_scoring(params)
      # TODO: Implement assert_level_2_auth and add_order_scoring_params_to_url
      request_args = Polymarket::RequestArgs.new(method: 'GET', request_path: Endpoints::IS_ORDER_SCORING)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::IS_ORDER_SCORING}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Get.new(uri.request_uri, headers)
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't check if order is scoring: #{response.body}"
        nil
      end
    end

    def are_orders_scoring(params)
      # TODO: Implement assert_level_2_auth
      body = params.orderIds
      request_args = Polymarket::RequestArgs.new(method: 'POST', request_path: Endpoints::ARE_ORDERS_SCORING, body: body)
      headers = Polymarket::Headers.create_level_2_headers(@signer, @creds, request_args)
      uri = URI.parse("#{@host}#{Endpoints::ARE_ORDERS_SCORING}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      request = Net::HTTP::Post.new(uri.request_uri, headers.merge('Content-Type' => 'application/json'))
      request.body = body.to_json
      response = http.request(request)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't check if orders are scoring: #{response.body}"
        nil
      end
    end

    def get_sampling_markets(next_cursor = 'MA==')
      uri = URI.parse("#{@host}#{Endpoints::GET_SAMPLING_MARKETS}?next_cursor=#{next_cursor}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get sampling markets: #{response.body}"
        nil
      end
    end

    def get_sampling_simplified_markets(next_cursor = 'MA==')
      uri = URI.parse("#{@host}#{Endpoints::GET_SAMPLING_SIMPLIFIED_MARKETS}?next_cursor=#{next_cursor}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get sampling simplified markets: #{response.body}"
        nil
      end
    end

    def get_markets(next_cursor = 'MA==')
      uri = URI.parse("#{@host}#{Endpoints::GET_MARKETS}?next_cursor=#{next_cursor}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get markets: #{response.body}"
        nil
      end
    end

    def get_simplified_markets(next_cursor = 'MA==')
      uri = URI.parse("#{@host}#{Endpoints::GET_SIMPLIFIED_MARKETS}?next_cursor=#{next_cursor}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get simplified markets: #{response.body}"
        nil
      end
    end

    def get_market(condition_id)
      uri = URI.parse("#{@host}#{Endpoints::GET_MARKET}#{condition_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market: #{response.body}"
        nil
      end
    end

    def get_market_trades_events(condition_id)
      uri = URI.parse("#{@host}#{Endpoints::GET_MARKET_TRADES_EVENTS}#{condition_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market trades events: #{response.body}"
        nil
      end
    end

    def calculate_market_price(token_id, side, amount, order_type)
      # TODO: Implement market price calculation logic
      nil
    end

    def assert_level_1_auth
      # TODO: Implement proper mode check and exception
      raise 'Level 1 Auth required' unless @mode && @mode >= 1
    end

    def assert_level_2_auth
      # TODO: Implement proper mode check and exception
      raise 'Level 2 Auth required' unless @mode && @mode >= 2
    end

    private

    def get_client_mode
      # 2 = L2, 1 = L1, 0 = L0
      if @signer && @creds
        2
      elsif @signer
        1
      else
        0
      end
    end
  end
end 