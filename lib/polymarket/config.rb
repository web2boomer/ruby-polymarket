# frozen_string_literal: true

module Polymarket
  class ContractConfig
    attr_accessor :exchange, :collateral, :conditional_tokens
    def initialize(exchange:, collateral:, conditional_tokens:)
      @exchange = exchange
      @collateral = collateral
      @conditional_tokens = conditional_tokens
    end
  end

  module Config
    CONFIG = {
      137 => ContractConfig.new(
        exchange: '0x4bFb41d5B3570DeFd03C39a9A4D8dE6Bd8B8982E',
        collateral: '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174',
        conditional_tokens: '0x4D97DCd97eC945f40cF65F87097ACe5EA0476045'
      ),
      80002 => ContractConfig.new(
        exchange: '0xdFE02Eb6733538f8Ea35D585af8DE5958AD99E40',
        collateral: '0x9c4e1703476e875070ee25b56a58b008cfb8fa78',
        conditional_tokens: '0x69308FB512518e39F9b16112fA8d994F4e2Bf8bB'
      )
    }

    NEG_RISK_CONFIG = {
      137 => ContractConfig.new(
        exchange: '0xC5d563A36AE78145C45a50134d48A1215220f80a',
        collateral: '0x2791bca1f2de4661ed88a30c99a7a9449aa84174',
        conditional_tokens: '0x4D97DCd97eC945f40cF65F87097ACe5EA0476045'
      ),
      80002 => ContractConfig.new(
        exchange: '0xd91E80cF2E7be2e162c6513ceD06f1dD0dA35296',
        collateral: '0x9c4e1703476e875070ee25b56a58b008cfb8fa78',
        conditional_tokens: '0x69308FB512518e39F9b16112fA8d994F4e2Bf8bB'
      )
    }

    def self.get_contract_config(chain_id, neg_risk = false)
      config = neg_risk ? NEG_RISK_CONFIG[chain_id] : CONFIG[chain_id]
      raise "Invalid chainID: #{chain_id}" if config.nil?
      config
    end
  end
end 