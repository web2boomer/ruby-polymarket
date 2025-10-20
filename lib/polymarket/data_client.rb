# frozen_string_literal: true
require 'net/http'
require 'uri'
require_relative 'constants'
require_relative 'data_endpoints'
require 'json'

module Polymarket
  class DataClient
    attr_reader :data_host

    def initialize(data_host: Constants::DEFAULT_DATA_HOST)
      # Remove trailing slash from host
      @data_host = data_host.end_with?('/') ? data_host[0..-2] : data_host
    end

    # Data API methods will be implemented here
    # These are placeholder methods for future implementation
    
    def get_markets
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKETS}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get markets: #{response.body}"
        nil
      end
    end

    def get_events
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENTS}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get events: #{response.body}"
        nil
      end
    end

    def get_activity(user: nil, market: nil, limit: nil, offset: nil)
      # Build query parameters
      params = {}
      params[:user] = user if user
      params[:market] = market if market
      params[:limit] = limit if limit
      params[:offset] = offset if offset
      
      # Build URI with query parameters
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_ACTIVITY}")
      uri.query = URI.encode_www_form(params) unless params.empty?
      
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get activity: #{response.body}"
        nil
      end
    end

    def get_market(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market: #{response.body}"
        nil
      end
    end

    def get_market_details(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_DETAILS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market details: #{response.body}"
        nil
      end
    end

    def get_market_activity(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_ACTIVITY}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market activity: #{response.body}"
        nil
      end
    end

    def get_market_trades(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_TRADES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market trades: #{response.body}"
        nil
      end
    end

    def get_market_orders(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_ORDERS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market orders: #{response.body}"
        nil
      end
    end

    def get_market_stats(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_STATS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market stats: #{response.body}"
        nil
      end
    end

    def get_market_history(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_HISTORY}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market history: #{response.body}"
        nil
      end
    end

    def get_market_outcomes(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_OUTCOMES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market outcomes: #{response.body}"
        nil
      end
    end

    def get_market_conditions(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_CONDITIONS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market conditions: #{response.body}"
        nil
      end
    end

    def get_market_resolution(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_RESOLUTION}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market resolution: #{response.body}"
        nil
      end
    end

    def get_market_volume(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_VOLUME}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market volume: #{response.body}"
        nil
      end
    end

    def get_market_liquidity(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_LIQUIDITY}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market liquidity: #{response.body}"
        nil
      end
    end

    def get_market_orderbook(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_ORDERBOOK}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market orderbook: #{response.body}"
        nil
      end
    end

    def get_market_prices(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_PRICES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market prices: #{response.body}"
        nil
      end
    end

    def get_market_spreads(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_SPREADS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market spreads: #{response.body}"
        nil
      end
    end

    def get_market_midpoints(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_MIDPOINTS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market midpoints: #{response.body}"
        nil
      end
    end

    def get_market_last_trades(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_LAST_TRADES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market last trades: #{response.body}"
        nil
      end
    end

    def get_market_tick_sizes(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_TICK_SIZES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market tick sizes: #{response.body}"
        nil
      end
    end

    def get_market_neg_risk(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_NEG_RISK}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market neg risk: #{response.body}"
        nil
      end
    end

    def get_market_notifications(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_NOTIFICATIONS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market notifications: #{response.body}"
        nil
      end
    end

    def get_market_balance(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_BALANCE}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market balance: #{response.body}"
        nil
      end
    end

    def get_market_allowance(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_ALLOWANCE}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market allowance: #{response.body}"
        nil
      end
    end

    def get_market_scoring(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_SCORING}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market scoring: #{response.body}"
        nil
      end
    end

    def get_market_sampling(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_SAMPLING}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market sampling: #{response.body}"
        nil
      end
    end

    def get_market_simplified(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_SIMPLIFIED}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market simplified: #{response.body}"
        nil
      end
    end

    def get_market_live_activity(market_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_MARKET_LIVE_ACTIVITY}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market live activity: #{response.body}"
        nil
      end
    end

    # Event-specific methods
    def get_event(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event: #{response.body}"
        nil
      end
    end

    def get_event_details(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_DETAILS}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event details: #{response.body}"
        nil
      end
    end

    def get_event_activity(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_ACTIVITY}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event activity: #{response.body}"
        nil
      end
    end

    def get_event_trades(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_TRADES}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event trades: #{response.body}"
        nil
      end
    end

    def get_event_orders(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_ORDERS}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event orders: #{response.body}"
        nil
      end
    end

    def get_event_stats(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_STATS}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event stats: #{response.body}"
        nil
      end
    end

    def get_event_history(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_HISTORY}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event history: #{response.body}"
        nil
      end
    end

    def get_event_outcomes(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_OUTCOMES}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event outcomes: #{response.body}"
        nil
      end
    end

    def get_event_conditions(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_CONDITIONS}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event conditions: #{response.body}"
        nil
      end
    end

    def get_event_resolution(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_RESOLUTION}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event resolution: #{response.body}"
        nil
      end
    end

    def get_event_volume(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_VOLUME}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event volume: #{response.body}"
        nil
      end
    end

    def get_event_liquidity(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_LIQUIDITY}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event liquidity: #{response.body}"
        nil
      end
    end

    def get_event_orderbook(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_ORDERBOOK}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event orderbook: #{response.body}"
        nil
      end
    end

    def get_event_prices(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_PRICES}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event prices: #{response.body}"
        nil
      end
    end

    def get_event_spreads(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_SPREADS}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event spreads: #{response.body}"
        nil
      end
    end

    def get_event_midpoints(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_MIDPOINTS}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event midpoints: #{response.body}"
        nil
      end
    end

    def get_event_last_trades(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_LAST_TRADES}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event last trades: #{response.body}"
        nil
      end
    end

    def get_event_tick_sizes(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_TICK_SIZES}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event tick sizes: #{response.body}"
        nil
      end
    end

    def get_event_neg_risk(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_NEG_RISK}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event neg risk: #{response.body}"
        nil
      end
    end

    def get_event_notifications(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_NOTIFICATIONS}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event notifications: #{response.body}"
        nil
      end
    end

    def get_event_balance(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_BALANCE}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event balance: #{response.body}"
        nil
      end
    end

    def get_event_allowance(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_ALLOWANCE}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event allowance: #{response.body}"
        nil
      end
    end

    def get_event_scoring(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_SCORING}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event scoring: #{response.body}"
        nil
      end
    end

    def get_event_sampling(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_SAMPLING}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event sampling: #{response.body}"
        nil
      end
    end

    def get_event_simplified(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_SIMPLIFIED}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event simplified: #{response.body}"
        nil
      end
    end

    def get_event_live_activity(event_id)
      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_EVENT_LIVE_ACTIVITY}/#{event_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get event live activity: #{response.body}"
        nil
      end
    end
  end
end
