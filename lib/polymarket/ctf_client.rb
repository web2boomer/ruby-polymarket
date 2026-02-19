# frozen_string_literal: true

require 'eth'
require 'digest/keccak'
require_relative 'constants'
require_relative 'clob_config'

module Polymarket
  class CTFClient
    attr_reader :chain_id, :signer, :ctf_address, :collateral_address, :provider

    # Initialize CTF client
    # @param chain_id [Integer] Chain ID (137 for Polygon, 80002 for Amoy)
    # @param key [String] Private key (optional, required for transaction signing)
    # @param provider [Object] Web3 provider (optional, for sending transactions)
    def initialize(chain_id: Constants::POLYGON, key: nil, provider: nil)
      @chain_id = chain_id
      @signer = key ? Signer.new(key, chain_id) : nil
      @provider = provider
      
      # Get contract addresses from CLOBConfig
      contract_config = CLOBConfig.get_contract_config(chain_id, false)
      @ctf_address = contract_config.conditional_tokens
      @collateral_address = contract_config.collateral
    end

    # Get the wallet address if signer is configured
    def get_address
      @signer ? @signer.address : nil
    end

    # Calculate conditionId from oracle, questionId, and outcomeSlotCount
    # @param oracle [String] Address of the oracle (UMA adapter V2)
    # @param question_id [String] Hash of the UMA ancillary data (bytes32)
    # @param outcome_slot_count [Integer] Number of outcome slots (2 for binary markets)
    # @return [String] conditionId as hex string
    def get_condition_id(oracle, question_id, outcome_slot_count = 2)
      # conditionId = keccak256(abi.encodePacked(oracle, questionId, outcomeSlotCount))
      # Remove 0x prefix if present
      oracle_clean = oracle.start_with?('0x') ? oracle[2..-1] : oracle
      question_id_clean = question_id.start_with?('0x') ? question_id[2..-1] : question_id
      
      # Pad addresses to 20 bytes (40 hex chars) and question_id to 32 bytes (64 hex chars)
      oracle_padded = oracle_clean.rjust(64, '0')
      question_id_padded = question_id_clean.rjust(64, '0')
      
      # Encode outcomeSlotCount as uint256 (64 hex chars)
      outcome_slot_count_hex = outcome_slot_count.to_s(16).rjust(64, '0')
      
      # Concatenate and hash
      packed = oracle_padded + question_id_padded + outcome_slot_count_hex
      hash = Digest::Keccak.digest([packed].pack('H*'), 256)
      '0x' + hash.unpack1('H*')
    end

    # Calculate collectionId from parentCollectionId, conditionId, and indexSet
    # @param parent_collection_id [String] Parent collection ID (bytes32(0) for Polymarket)
    # @param condition_id [String] Condition ID (bytes32)
    # @param index_set [Integer] Index set (1 for first outcome, 2 for second outcome in binary markets)
    # @return [String] collectionId as hex string
    def get_collection_id(parent_collection_id, condition_id, index_set)
      # collectionId = keccak256(abi.encodePacked(parentCollectionId, conditionId, indexSet))
      parent_clean = parent_collection_id.start_with?('0x') ? parent_collection_id[2..-1] : parent_collection_id
      condition_clean = condition_id.start_with?('0x') ? condition_id[2..-1] : condition_id
      
      # Pad to 32 bytes (64 hex chars)
      parent_padded = parent_clean.rjust(64, '0')
      condition_padded = condition_clean.rjust(64, '0')
      
      # Encode indexSet as uint256 (64 hex chars)
      index_set_hex = index_set.to_s(16).rjust(64, '0')
      
      # Concatenate and hash
      packed = parent_padded + condition_padded + index_set_hex
      hash = Digest::Keccak.digest([packed].pack('H*'), 256)
      '0x' + hash.unpack1('H*')
    end

    # Calculate positionId from collateralToken and collectionId
    # @param collateral_token [String] Address of the collateral token (USDC)
    # @param collection_id [String] Collection ID (bytes32)
    # @return [String] positionId as hex string
    def get_position_id(collateral_token, collection_id)
      # positionId = keccak256(abi.encodePacked(collateralToken, collectionId))
      collateral_clean = collateral_token.start_with?('0x') ? collateral_token[2..-1] : collateral_token
      collection_clean = collection_id.start_with?('0x') ? collection_id[2..-1] : collection_id
      
      # Pad addresses to 20 bytes (40 hex chars) and collection_id to 32 bytes (64 hex chars)
      collateral_padded = collateral_clean.rjust(64, '0')
      collection_padded = collection_clean.rjust(64, '0')
      
      # Concatenate and hash
      packed = collateral_padded + collection_padded
      hash = Digest::Keccak.digest([packed].pack('H*'), 256)
      '0x' + hash.unpack1('H*')
    end

    # Get both position IDs (YES and NO) for a condition
    # @param condition_id [String] Condition ID
    # @param collateral_token [String] Collateral token address (defaults to configured USDC)
    # @return [Hash] Hash with :yes and :no position IDs
    def get_position_ids(condition_id, collateral_token: nil)
      collateral_token ||= @collateral_address
      parent_collection_id = '0x' + '0' * 64
      
      yes_collection_id = get_collection_id(parent_collection_id, condition_id, 1)
      no_collection_id = get_collection_id(parent_collection_id, condition_id, 2)
      
      {
        yes: get_position_id(collateral_token, yes_collection_id),
        no: get_position_id(collateral_token, no_collection_id)
      }
    end

    # Build transaction data for splitPosition
    # @param condition_id [String] Condition ID
    # @param amount [Integer] Amount of collateral to split (in token units, e.g., 1000000 for 1 USDC with 6 decimals)
    # @param collateral_token [String] Collateral token address (defaults to configured USDC)
    # @return [Hash] Transaction data hash with :to, :data, :value
    def build_split_transaction(condition_id, amount, collateral_token: nil)
      collateral_token ||= @collateral_address
      parent_collection_id = '0x' + '0' * 64
      partition = [1, 2] # Binary market partition
      
      # Function signature: splitPosition(address,bytes32,bytes32,uint256[],uint256)
      function_hash = Digest::Keccak.digest('splitPosition(address,bytes32,bytes32,uint256[],uint256)', 256)
      function_signature = '0x' + function_hash[0..3].unpack1('H*')
      
      # Encode parameters
      # address: 32 bytes (padded to left)
      collateral_encoded = encode_address(collateral_token)
      # bytes32: 32 bytes
      parent_encoded = encode_bytes32(parent_collection_id)
      # bytes32: 32 bytes
      condition_encoded = encode_bytes32(condition_id)
      # uint256[]: offset (32 bytes) + length (32 bytes) + values (32 bytes each)
      partition_offset = '00000000000000000000000000000000000000000000000000000000000000a0' # 160 in hex
      partition_length = encode_uint256(partition.length)
      partition_values = partition.map { |p| encode_uint256(p) }.join
      # uint256: 32 bytes
      amount_encoded = encode_uint256(amount)
      
      # Combine all parameters
      data = function_signature + collateral_encoded + parent_encoded + condition_encoded + 
             partition_offset + amount_encoded + partition_length + partition_values
      
      {
        to: @ctf_address,
        data: data,
        value: '0x0'
      }
    end

    # Build transaction data for mergePositions
    # @param condition_id [String] Condition ID
    # @param amount [Integer] Number of full sets to merge (in token units)
    # @param collateral_token [String] Collateral token address (defaults to configured USDC)
    # @return [Hash] Transaction data hash with :to, :data, :value
    def build_merge_transaction(condition_id, amount, collateral_token: nil)
      collateral_token ||= @collateral_address
      parent_collection_id = '0x' + '0' * 64
      partition = [1, 2] # Binary market partition
      
      # Function signature: mergePositions(address,bytes32,bytes32,uint256[],uint256)
      function_hash = Digest::Keccak.digest('mergePositions(address,bytes32,bytes32,uint256[],uint256)', 256)
      function_signature = '0x' + function_hash[0..3].unpack1('H*')
      
      # Encode parameters (same as split)
      collateral_encoded = encode_address(collateral_token)
      parent_encoded = encode_bytes32(parent_collection_id)
      condition_encoded = encode_bytes32(condition_id)
      partition_offset = '00000000000000000000000000000000000000000000000000000000000000a0'
      partition_length = encode_uint256(partition.length)
      partition_values = partition.map { |p| encode_uint256(p) }.join
      amount_encoded = encode_uint256(amount)
      
      data = function_signature + collateral_encoded + parent_encoded + condition_encoded + 
             partition_offset + amount_encoded + partition_length + partition_values
      
      {
        to: @ctf_address,
        data: data,
        value: '0x0'
      }
    end

    # Build transaction data for redeemPositions
    # @param condition_id [String] Condition ID
    # @param collateral_token [String] Collateral token address (defaults to configured USDC)
    # @return [Hash] Transaction data hash with :to, :data, :value
    def build_redeem_transaction(condition_id, collateral_token: nil)
      collateral_token ||= @collateral_address
      parent_collection_id = '0x' + '0' * 64
      index_sets = [1, 2] # Both outcomes for binary markets
      
      # Function signature: redeemPositions(address,bytes32,bytes32,uint256[])
      function_hash = Digest::Keccak.digest('redeemPositions(address,bytes32,bytes32,uint256[])', 256)
      function_signature = '0x' + function_hash[0..3].unpack1('H*')
      
      # Encode parameters
      collateral_encoded = encode_address(collateral_token)
      parent_encoded = encode_bytes32(parent_collection_id)
      condition_encoded = encode_bytes32(condition_id)
      index_sets_offset = '0000000000000000000000000000000000000000000000000000000000000080' # 128 in hex
      index_sets_length = encode_uint256(index_sets.length)
      index_sets_values = index_sets.map { |s| encode_uint256(s) }.join
      
      data = function_signature + collateral_encoded + parent_encoded + condition_encoded + 
             index_sets_offset + index_sets_length + index_sets_values
      
      {
        to: @ctf_address,
        data: data,
        value: '0x0'
      }
    end

    # Split USDC into YES and NO tokens
    # @param condition_id [String] Condition ID
    # @param amount [Integer] Amount of collateral to split (in token units, e.g., 1000000 for 1 USDC with 6 decimals)
    # @param collateral_token [String] Collateral token address (optional)
    # @return [Hash] Transaction data or transaction receipt if provider is configured
    def split(condition_id, amount, collateral_token: nil)
      tx_data = build_split_transaction(condition_id, amount, collateral_token: collateral_token)
      
      if @provider && @signer
        send_transaction(tx_data)
      else
        tx_data
      end
    end

    # Merge YES and NO tokens back into USDC
    # @param condition_id [String] Condition ID
    # @param amount [Integer] Number of full sets to merge (in token units)
    # @param collateral_token [String] Collateral token address (optional)
    # @return [Hash] Transaction data or transaction receipt if provider is configured
    def merge(condition_id, amount, collateral_token: nil)
      tx_data = build_merge_transaction(condition_id, amount, collateral_token: collateral_token)
      
      if @provider && @signer
        send_transaction(tx_data)
      else
        tx_data
      end
    end

    # Redeem winning outcome tokens for collateral
    # @param condition_id [String] Condition ID
    # @param collateral_token [String] Collateral token address (optional)
    # @return [Hash] Transaction data or transaction receipt if provider is configured
    def redeem(condition_id, collateral_token: nil)
      tx_data = build_redeem_transaction(condition_id, collateral_token: collateral_token)
      
      if @provider && @signer
        send_transaction(tx_data)
      else
        tx_data
      end
    end

    private

    # Encode an address as 32-byte hex string (left-padded)
    def encode_address(address)
      address_clean = address.start_with?('0x') ? address[2..-1] : address
      address_clean.rjust(64, '0')
    end

    # Encode a bytes32 value as 32-byte hex string
    def encode_bytes32(value)
      value_clean = value.start_with?('0x') ? value[2..-1] : value
      value_clean.rjust(64, '0')
    end

    # Encode a uint256 value as 32-byte hex string
    def encode_uint256(value)
      value.to_s(16).rjust(64, '0')
    end

    # Send a transaction using the provider
    def send_transaction(tx_data)
      raise 'Provider not configured' unless @provider
      raise 'Signer not configured' unless @signer
      
      # This is a placeholder - actual implementation depends on the provider interface
      # The provider should handle transaction signing and sending
      if @provider.respond_to?(:send_transaction)
        @provider.send_transaction(tx_data, @signer)
      else
        raise 'Provider does not support send_transaction method'
      end
    end
  end
end

