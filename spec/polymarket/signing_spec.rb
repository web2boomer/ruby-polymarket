# frozen_string_literal: true

require "spec_helper"

RSpec.describe Polymarket::Signing do
  describe "HMAC" do
    describe ".build_hmac_signature" do
      let(:secret) { Base64.urlsafe_encode64("test_secret_key") }
      let(:timestamp) { 1234567890 }
      let(:method) { "GET" }
      let(:request_path) { "/api/v1/test" }
      let(:body) { '{"test": "data"}' }

      it "creates an HMAC signature" do
        signature = described_class::HMAC.build_hmac_signature(secret, timestamp, method, request_path, body)

        expect(signature).to be_a(String)
        expect(signature.length).to be > 0
      end

      it "returns base64 encoded signature" do
        signature = described_class::HMAC.build_hmac_signature(secret, timestamp, method, request_path, body)

        # Base64 URL-safe encoded strings should only contain alphanumeric, -, _, and = (padding)
        expect(signature).to match(/\A[A-Za-z0-9_-]+=*\z/)
      end

      it "creates different signatures for different timestamps" do
        sig1 = described_class::HMAC.build_hmac_signature(secret, 1000, method, request_path, body)
        sig2 = described_class::HMAC.build_hmac_signature(secret, 2000, method, request_path, body)

        expect(sig1).not_to eq(sig2)
      end

      it "creates different signatures for different methods" do
        sig1 = described_class::HMAC.build_hmac_signature(secret, timestamp, "GET", request_path, body)
        sig2 = described_class::HMAC.build_hmac_signature(secret, timestamp, "POST", request_path, body)

        expect(sig1).not_to eq(sig2)
      end

      it "creates different signatures for different request paths" do
        sig1 = described_class::HMAC.build_hmac_signature(secret, timestamp, method, "/api/v1/test1", body)
        sig2 = described_class::HMAC.build_hmac_signature(secret, timestamp, method, "/api/v1/test2", body)

        expect(sig1).not_to eq(sig2)
      end

      it "creates different signatures for different bodies" do
        sig1 = described_class::HMAC.build_hmac_signature(secret, timestamp, method, request_path, '{"a": 1}')
        sig2 = described_class::HMAC.build_hmac_signature(secret, timestamp, method, request_path, '{"b": 2}')

        expect(sig1).not_to eq(sig2)
      end

      it "handles nil body" do
        signature = described_class::HMAC.build_hmac_signature(secret, timestamp, method, request_path, nil)

        expect(signature).to be_a(String)
      end

      it "uppercases the method" do
        sig_lower = described_class::HMAC.build_hmac_signature(secret, timestamp, "get", request_path, body)
        sig_upper = described_class::HMAC.build_hmac_signature(secret, timestamp, "GET", request_path, body)

        expect(sig_lower).to eq(sig_upper)
      end
    end
  end

  describe "Model" do
    describe ".keccak256" do
      it "hashes data using keccak256" do
        data = "test data"
        hash = described_class::Model.keccak256(data)

        expect(hash).to be_a(String)
        expect(hash.length).to eq(32) # keccak256 produces 32-byte hash
      end

      it "produces consistent hashes" do
        data = "test data"
        hash1 = described_class::Model.keccak256(data)
        hash2 = described_class::Model.keccak256(data)

        expect(hash1).to eq(hash2)
      end

      it "produces different hashes for different data" do
        hash1 = described_class::Model.keccak256("data1")
        hash2 = described_class::Model.keccak256("data2")

        expect(hash1).not_to eq(hash2)
      end
    end

    describe ".encode_uint256" do
      it "encodes a valid uint256 value" do
        encoded = described_class::Model.encode_uint256(12345)

        expect(encoded).to be_a(String)
        expect(encoded.length).to eq(32) # uint256 is 32 bytes
      end

      it "raises ArgumentError for negative values" do
        expect {
          described_class::Model.encode_uint256(-1)
        }.to raise_error(ArgumentError, "uint256 out of range")
      end

      it "raises ArgumentError for values >= 2^256" do
        large_value = 2**256
        expect {
          described_class::Model.encode_uint256(large_value)
        }.to raise_error(ArgumentError, "uint256 out of range")
      end

      it "converts string numbers to integers" do
        encoded1 = described_class::Model.encode_uint256("12345")
        encoded2 = described_class::Model.encode_uint256(12345)

        expect(encoded1).to eq(encoded2)
      end
    end

    describe ".encode_address" do
      it "encodes an address with 0x prefix" do
        address = "0x1234567890123456789012345678901234567890"
        encoded = described_class::Model.encode_address(address)

        expect(encoded).to be_a(String)
        expect(encoded.length).to eq(32) # address is 32 bytes (left-padded)
      end

      it "encodes an address without 0x prefix" do
        address = "1234567890123456789012345678901234567890"
        encoded = described_class::Model.encode_address(address)

        expect(encoded).to be_a(String)
        expect(encoded.length).to eq(32)
      end

      it "returns empty string for nil address" do
        encoded = described_class::Model.encode_address(nil)

        expect(encoded).to eq("")
      end
    end

    describe ".encode_string" do
      it "hashes a string using keccak256" do
        str = "test string"
        encoded = described_class::Model.encode_string(str)

        expect(encoded).to be_a(String)
        expect(encoded.length).to eq(32) # keccak256 produces 32-byte hash
      end

      it "converts non-strings to strings" do
        encoded1 = described_class::Model.encode_string(12345)
        encoded2 = described_class::Model.encode_string("12345")

        expect(encoded1).to eq(encoded2)
      end
    end
  end

  describe "EIP712" do
    describe ".prepend_zx" do
      it "adds 0x prefix if missing" do
        result = described_class::EIP712.prepend_zx("abc123")

        expect(result).to eq("0xabc123")
      end

      it "does not add prefix if already present" do
        result = described_class::EIP712.prepend_zx("0xabc123")

        expect(result).to eq("0xabc123")
      end
    end

    describe ".get_clob_auth_domain" do
      it "creates domain without contract config" do
        domain = described_class::EIP712.get_clob_auth_domain(137)

        expect(domain).to be_a(Hash)
        expect(domain[:name]).to eq("ClobAuthDomain")
        expect(domain[:version]).to eq("1")
        expect(domain[:chainId]).to eq(137)
        expect(domain[:verifyingContract]).to be_nil
      end

      it "creates domain with contract config" do
        contract_config = Polymarket::ClobTypes::ContractConfig.new(
          exchange: "0x1234567890123456789012345678901234567890",
          collateral: "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
          conditional_tokens: "0x9876543210987654321098765432109876543210"
        )
        domain = described_class::EIP712.get_clob_auth_domain(137, contract_config)

        expect(domain[:name]).to eq("Polymarket CTF Exchange")
        expect(domain[:verifyingContract]).to eq(contract_config.exchange)
      end
    end

    describe ".sign_clob_auth_message" do
      let(:private_key) { "0x" + "1" * 64 }
      let(:chain_id) { 137 }
      let(:signer) { Polymarket::Signer.new(private_key, chain_id) }
      let(:timestamp) { 1234567890 }
      let(:nonce) { 12345 }

      it "signs a CLOB auth message" do
        signature = described_class::EIP712.sign_clob_auth_message(signer, timestamp, nonce)

        expect(signature).to be_a(String)
        expect(signature).to start_with("0x")
      end

      it "produces different signatures for different timestamps" do
        sig1 = described_class::EIP712.sign_clob_auth_message(signer, 1000, nonce)
        sig2 = described_class::EIP712.sign_clob_auth_message(signer, 2000, nonce)

        expect(sig1).not_to eq(sig2)
      end

      it "produces different signatures for different nonces" do
        sig1 = described_class::EIP712.sign_clob_auth_message(signer, timestamp, 1)
        sig2 = described_class::EIP712.sign_clob_auth_message(signer, timestamp, 2)

        expect(sig1).not_to eq(sig2)
      end
    end
  end

  describe "ClobAuth" do
    let(:address) { "0x1234567890123456789012345678901234567890" }
    let(:timestamp) { 1234567890 }
    let(:nonce) { 12345 }
    let(:message) { "test message" }
    let(:clob_auth) { described_class::ClobAuth.new(address: address, timestamp: timestamp, nonce: nonce, message: message) }

    describe "#initialize" do
      it "creates a ClobAuth instance" do
        expect(clob_auth).to be_a(described_class::ClobAuth)
        expect(clob_auth.address).to eq(address)
        expect(clob_auth.timestamp).to eq(timestamp)
        expect(clob_auth.nonce).to eq(nonce)
        expect(clob_auth.message).to eq(message)
      end
    end

    describe "#signable_bytes" do
      let(:domain) { { name: "TestDomain", version: "1", chainId: 137 } }

      it "generates signable bytes" do
        bytes = clob_auth.signable_bytes(domain)

        expect(bytes).to be_a(String)
        expect(bytes.length).to eq(32) # keccak256 digest is 32 bytes
      end

      it "produces consistent bytes for same inputs" do
        bytes1 = clob_auth.signable_bytes(domain)
        bytes2 = clob_auth.signable_bytes(domain)

        expect(bytes1).to eq(bytes2)
      end

      it "produces different bytes for different domains" do
        domain1 = { name: "TestDomain", version: "1", chainId: 137 }
        domain2 = { name: "TestDomain", version: "1", chainId: 80002 }

        bytes1 = clob_auth.signable_bytes(domain1)
        bytes2 = clob_auth.signable_bytes(domain2)

        expect(bytes1).not_to eq(bytes2)
      end
    end
  end
end
