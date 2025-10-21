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

    def get_events(limit: nil, offset: nil, order: nil, ascending: nil, id: nil, slug: nil, start_date_min: nil, start_date_max: nil, end_date_min: nil, end_date_max: nil)
      params = {}
      params[:limit] = limit if limit
      params[:offset] = offset if offset
      params[:order] = order if order
      params[:ascending] = ascending unless ascending.nil?
      params[:id] = id if id
      params[:slug] = slug if slug
      params[:start_date_min] = start_date_min if start_date_min
      params[:start_date_max] = start_date_max if start_date_max
      params[:end_date_min] = end_date_min if end_date_min
      params[:end_date_max] = end_date_max if end_date_max

      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_EVENTS}")
      uri.query = URI.encode_www_form(params) unless params.empty?
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

    def get_market_by_slug(market_slug)
      uri = URI.parse("#{@gamma_host}#{GammaEndpoints::GET_MARKET_BY_SLUG}/#{market_slug}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get market by slug: #{response.body}"
        nil
      end
    end

  end
end
