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


    def get_positions(user:, limit: nil, offset: nil)
      params = { user: user }
      params[:limit] = limit if limit
      params[:offset] = offset if offset

      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_POSITIONS}")
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get positions: #{response.body}"
      end
    end

    def get_closed_positions(user:, limit: nil, offset: nil)
      params = { user: user }
      params[:limit] = limit if limit
      params[:offset] = offset if offset

      uri = URI.parse("#{@data_host}#{DataEndpoints::GET_CLOSED_POSITIONS}")
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body)
      else
        raise "Couldn't get closed positions: #{response.body}"
      end
    end

    def get_activity(user: , market: nil, event_id: nil, limit: nil, offset: nil, type: nil)
      # Build query parameters
      params = {}
      params[:user] = user if user
      params[:market] = market if market
      params[:limit] = limit if limit
      params[:offset] = offset if offset
      params[:event_id] = event_id if event_id
      params[:type] = type if type
      
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

  end
end
