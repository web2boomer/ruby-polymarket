# frozen_string_literal: true
require 'openssl'
require 'base64'
require 'eth'
require 'digest/keccak'

module Polymarket
  module Signing
    # === HMAC ===
    module HMAC

      
      def self.build_hmac_signature(secret, timestamp, method, request_path, body = nil)
        base64_secret = Base64.urlsafe_decode64(secret)
        normalized_body = body ? body : ""
        message = "#{timestamp}#{method.upcase}#{request_path}#{normalized_body}"
        
        # Debug logging
        # puts  "[HMAC DEBUG] Secret (base64): #{secret}" 
        # puts  "[HMAC DEBUG] Timestamp: #{timestamp}" 
        # puts  "[HMAC DEBUG] Method: #{method}" 
        # puts  "[HMAC DEBUG] Request path: #{request_path}" 
        # puts  "[HMAC DEBUG] Body: #{normalized_body}" 
        # puts  "[HMAC DEBUG] Message to sign: #{message}" 
        
        hmac = OpenSSL::HMAC.digest('sha256', base64_secret, message.encode('UTF-8'))
        signature = Base64.urlsafe_encode64(hmac)
        
        # puts  "[HMAC DEBUG] Generated signature: #{signature}" 
        
        signature
      end
    end

    # === MODEL ===
    module Model
      def self.keccak256(data)
        Digest::Keccak.digest(data, 256)
      end

      def self.encode_uint256(val)
        val = val.to_i
        raise ArgumentError, "uint256 out of range" if val < 0 || val >= 2**256
        [val.to_s(16).rjust(64, '0')].pack('H*')
      end

      def self.encode_uint8(val)
        [val.to_i].pack('C').rjust(32, "\x00")
      end

      def self.encode_address(addr)
        return "" unless addr
        [addr.sub(/^0x/, '')].pack('H*').rjust(32, "\x00")
      end

      def self.encode_string(str)
        keccak256(str.to_s)
      end

      def self.domain_separator_hash(domain)
        # puts "[DEBUG] domain in domain_separator_hash: #{domain.inspect}"
        name_hash     = encode_string(domain[:name])
        version_hash  = encode_string(domain[:version])
        chain_id_enc  = encode_uint256(domain[:chainId])

        if domain[:verifyingContract]
          type_hash     = encode_string("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
          contract_enc  = encode_address(domain[:verifyingContract])
          packed = type_hash + name_hash + version_hash + chain_id_enc + contract_enc
        else
          type_hash     = encode_string("EIP712Domain(string name,string version,uint256 chainId)")
          packed = type_hash + name_hash + version_hash + chain_id_enc
        end
        keccak256(packed)
      end

      def self.create_eip712_digest(domain_separator, struct_hash)
        to_sign = "\x19\x01" + domain_separator + struct_hash
        encode_string(to_sign)
      end
    end

    class ClobAuth
      attr_accessor :address, :timestamp, :nonce, :message

      def initialize(address:, timestamp:, nonce:, message:)
        @address = address
        @timestamp = timestamp
        @nonce = nonce
        @message = message
      end

      TYPE_HASH = Model.keccak256("ClobAuth(address address,string timestamp,uint256 nonce,string message)")

      def signable_bytes(domain)
        address_enc    = Model.encode_address(@address)
        timestamp_enc  = Model.encode_string(@timestamp.to_s)
        nonce_enc      = Model.encode_uint256(@nonce.to_i)
        message_enc    = Model.encode_string(@message)
        
        packed = TYPE_HASH + address_enc + timestamp_enc + nonce_enc + message_enc
        struct_hash = Model.keccak256(packed)
        domain_separator = Model.domain_separator_hash(domain)
        # puts "domain_separator: #{domain_separator.unpack1('H*')}"
        digest = Model.create_eip712_digest(domain_separator, struct_hash)
        # puts "digest: #{struct_hash.unpack1('H*')}"
        digest
      end
    end

    class OrderStruct
      attr_accessor :maker, :taker, :token_id, :maker_amount, :taker_amount, :side, :fee_rate_bps, :nonce, :signer, :expiration, :signature, :signature_type, :salt, :digest

      def initialize(maker:, taker:, token_id:, maker_amount:, taker_amount:, side:, fee_rate_bps:, nonce:, signer:, expiration:, signature_type:, salt:)
        @maker           = maker           # Maker of the order, i.e the source of funds for the order
        @taker           = taker           # Address of the order taker. The zero address is used to indicate a public order
        @token_id        = token_id        # Token Id of the CTF ERC1155 asset to be bought or sold
        @maker_amount    = maker_amount    # Maker amount, i.e the max amount of tokens to be sold
        @taker_amount    = taker_amount    # Taker amount, i.e the minimum amount of tokens to be received
        @side            = side            # The side of the order, BUY or SELL
        @fee_rate_bps    = fee_rate_bps    # Fee rate, in basis points, charged to the order maker, charged on proceeds
        @nonce           = nonce           # Nonce used for onchain cancellations
        @signer          = signer          # Signer of the order. Optional, if it is not present the signer is the maker of the order
        @expiration      = expiration      # Timestamp after which the order is expired
        @signature_type  = signature_type  # Signature type used by the Order. Default value 'EOA'
        @salt            = salt            # Unique salt to ensure entropy

        # set defaults if not set 
        @taker ||= Polymarket::Constants::ZERO_ADDRESS
        @nonce ||= "0"
        @expiration ||= "0"
        @signature_type ||= SignatureType::EOA        
      end

      def to_h
      {
        salt: @salt,
        maker: @maker,
        signer: @signer,
        taker: @taker,
        token_id: @token_id,
        maker_amount: @maker_amount,
        taker_amount: @taker_amount,
        expiration: @expiration,
        nonce: @nonce,
        fee_rate_bps: @fee_rate_bps,
        side: @side,
        signature_type: @signature_type,
        signature: @signature
      }
      end

      TYPE_HASH = Model.keccak256("Order(uint256 salt,address maker,address signer,address taker,uint256 tokenId,uint256 makerAmount,uint256 takerAmount,uint256 expiration,uint256 nonce,uint256 feeRateBps,uint8 side,uint8 signatureType)")

      def signable_bytes(domain)
        # Solidity type: uint256
        salt_enc        = Model.encode_uint256(@salt)
        token_id_enc    = Model.encode_uint256(@token_id)
        maker_amt_enc   = Model.encode_uint256(@maker_amount)
        taker_amt_enc   = Model.encode_uint256(@taker_amount)
        expiration_enc  = Model.encode_uint256(@expiration)
        nonce_enc       = Model.encode_uint256(@nonce)
        fee_bps_enc     = Model.encode_uint256(@fee_rate_bps)

        # Solidity type: address (20-byte left-padded)
        maker_enc       = Model.encode_address(@maker)
        signer_enc      = Model.encode_address(@signer)
        taker_enc       = Model.encode_address(@taker)

        # Solidity type: uint8
        side_enc        = Model.encode_uint8(@side.to_i)
        sig_type_enc    = Model.encode_uint8(@signature_type.to_i)

        packed = TYPE_HASH + salt_enc + maker_enc + signer_enc + taker_enc +
                 token_id_enc + maker_amt_enc + taker_amt_enc + expiration_enc +
                 nonce_enc + fee_bps_enc + side_enc + sig_type_enc

        struct_hash = Model.keccak256(packed) # need .pack("H*") ?
        domain_separator = Model.domain_separator_hash(domain)
        puts "domain_separator: #{domain_separator.unpack1('H*')}"
        digest = Model.create_eip712_digest(domain_separator, struct_hash)
        puts "digest: #{struct_hash.unpack1('H*')}"
        digest
      end


    end

    # === EIP712 ===
    module EIP712
      CLOB_DOMAIN_NAME = 'ClobAuthDomain'
      CLOB_VERSION = '1'
      MSG_TO_SIGN = 'This message attests that I control the given wallet'

      def self.prepend_zx(hex_string)
        return hex_string if hex_string.start_with?('0x')
        "0x#{hex_string}"
      end

      def self.get_clob_auth_domain(chain_id, contract_config = nil)
        domain = Hash.new
        domain[:name] = CLOB_DOMAIN_NAME
        domain[:name] = "Polymarket CTF Exchange" if contract_config
        domain[:version] = CLOB_VERSION
        domain[:chainId] = chain_id
        domain[:verifyingContract] = contract_config.exchange if contract_config&.exchange
        domain
      end

      def self.sign_clob_auth_message(signer, timestamp, nonce)
        domain = get_clob_auth_domain(signer.get_chain_id)

        clob_auth = Polymarket::Signing::ClobAuth.new(
          address: signer.address,
          timestamp: timestamp.to_s, 
          nonce: nonce.to_i,             
          message: MSG_TO_SIGN
        )

        # Strict EIP-712: sign the digest directly
        signable_data = clob_auth.signable_bytes(domain)
        
        # Debug: log the signable data
        # puts  "[SIGNING DEBUG] Signable data (hex): #{signable_data.unpack1('H*')}" 
        # puts  "[SIGNING DEBUG] Address: #{signer.address}" 
        # puts  "[SIGNING DEBUG] Timestamp: #{timestamp}" 
        # puts  "[SIGNING DEBUG] Nonce: #{nonce}" 

        signature = signer.sign(signable_data)
        
        # Debug: log the signature
        # puts  "[SIGNING DEBUG] Raw signature: #{signature}" 
        
        signature
      end
      

    end
  end
end 