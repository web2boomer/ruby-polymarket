# frozen_string_literal: true
require 'net/http'
require 'uri'
require_relative 'constants'
require_relative 'gamma_endpoints'
require 'json'

module Polymarket
  class GammaClient
    attr_reader :gamma_host

    def initialize(gamma_host: Constants::DEFAULT_GAMMA_HOST)
      # Remove trailing slash from host
      @gamma_host = gamma_host.end_with?('/') ? gamma_host[0..-2] : gamma_host
    end

    # Gamma API methods will be implemented here
    # These are placeholder methods for future implementation
    
    def get_markets
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKETS}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get markets: #{response.body}"
        nil
      end
    end

    def get_events
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_EVENTS}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get events: #{response.body}"
        nil
      end
    end

    def get_market(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market: #{response.body}"
        nil
      end
    end

    def get_market_details(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_DETAILS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market details: #{response.body}"
        nil
      end
    end

    def get_market_activity(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_ACTIVITY}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market activity: #{response.body}"
        nil
      end
    end

    def get_market_trades(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_TRADES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market trades: #{response.body}"
        nil
      end
    end

    def get_market_orders(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_ORDERS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market orders: #{response.body}"
        nil
      end
    end

    def get_market_stats(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_STATS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market stats: #{response.body}"
        nil
      end
    end

    def get_market_history(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_HISTORY}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market history: #{response.body}"
        nil
      end
    end

    def get_market_outcomes(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_OUTCOMES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market outcomes: #{response.body}"
        nil
      end
    end

    def get_market_conditions(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_CONDITIONS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market conditions: #{response.body}"
        nil
      end
    end

    def get_market_resolution(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_RESOLUTION}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market resolution: #{response.body}"
        nil
      end
    end

    def get_market_volume(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_VOLUME}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market volume: #{response.body}"
        nil
      end
    end

    def get_market_liquidity(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_LIQUIDITY}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market liquidity: #{response.body}"
        nil
      end
    end

    def get_market_orderbook(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_ORDERBOOK}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market orderbook: #{response.body}"
        nil
      end
    end

    def get_market_prices(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_PRICES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market prices: #{response.body}"
        nil
      end
    end

    def get_market_spreads(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_SPREADS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market spreads: #{response.body}"
        nil
      end
    end

    def get_market_midpoints(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_MIDPOINTS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market midpoints: #{response.body}"
        nil
      end
    end

    def get_market_last_trades(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_LAST_TRADES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market last trades: #{response.body}"
        nil
      end
    end

    def get_market_tick_sizes(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_TICK_SIZES}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market tick sizes: #{response.body}"
        nil
      end
    end

    def get_market_neg_risk(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_NEG_RISK}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market neg risk: #{response.body}"
        nil
      end
    end

    def get_market_notifications(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_NOTIFICATIONS}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market notifications: #{response.body}"
        nil
      end
    end

    def get_market_balance(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_BALANCE}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market balance: #{response.body}"
        nil
      end
    end

    def get_market_allowance(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_ALLOWANCE}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market allowance: #{response.body}"
        nil
      end
    end

    def get_market_scoring(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_SCORING}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market scoring: #{response.body}"
        nil
      end
    end

    def get_market_sampling(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_SAMPLING}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market sampling: #{response.body}"
        nil
      end
    end

    def get_market_simplified(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_SIMPLIFIED}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market simplified: #{response.body}"
        nil
      end
    end

    def get_market_live_activity(market_id)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_LIVE_ACTIVITY}/#{market_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market live activity: #{response.body}"
        nil
      end
    end
  end
end
