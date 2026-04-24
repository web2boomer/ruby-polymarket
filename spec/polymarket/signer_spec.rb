# frozen_string_literal: true

require "spec_helper"

RSpec.describe Polymarket::Signer do
  let(:valid_private_key) { "0x" + "1" * 64 }
  let(:chain_id) { 137 }

  describe "#initialize" do
    it "creates a signer with valid private key and chain_id" do
      signer = described_class.new(valid_private_key, chain_id)

      expect(signer).to be_a(Polymarket::Signer)
      expect(signer.private_key).to eq(valid_private_key)
      expect(signer.chain_id).to eq(chain_id)
    end

    it "raises ArgumentError when private_key is nil" do
      expect {
        described_class.new(nil, chain_id)
      }.to raise_error(ArgumentError, "private_key and chain_id are required")
    end

    it "raises ArgumentError when chain_id is nil" do
      expect {
        described_class.new(valid_private_key, nil)
      }.to raise_error(ArgumentError, "private_key and chain_id are required")
    end

    it "raises ArgumentError when both are nil" do
      expect {
        described_class.new(nil, nil)
      }.to raise_error(ArgumentError, "private_key and chain_id are required")
    end
  end

  describe "#address" do
    it "returns the address derived from the private key" do
      signer = described_class.new(valid_private_key, chain_id)
      address = signer.address

      expect(address).to be_a(String)
      expect(address).to start_with("0x")
      expect(address.length).to eq(42) # 0x + 40 hex chars
    end

    it "returns the same address for the same private key" do
      signer1 = described_class.new(valid_private_key, chain_id)
      signer2 = described_class.new(valid_private_key, chain_id)

      expect(signer1.address).to eq(signer2.address)
    end

    it "returns different addresses for different private keys" do
      key1 = "0x" + "1" * 64
      key2 = "0x" + "2" * 64

      signer1 = described_class.new(key1, chain_id)
      signer2 = described_class.new(key2, chain_id)

      expect(signer1.address).not_to eq(signer2.address)
    end
  end

  describe "#get_chain_id" do
    it "returns the chain_id" do
      signer = described_class.new(valid_private_key, chain_id)

      expect(signer.get_chain_id).to eq(chain_id)
    end

    it "returns different chain_ids for different signers" do
      signer1 = described_class.new(valid_private_key, 137)
      signer2 = described_class.new(valid_private_key, 80002)

      expect(signer1.get_chain_id).to eq(137)
      expect(signer2.get_chain_id).to eq(80002)
    end
  end

  describe "#sign" do
    let(:signer) { described_class.new(valid_private_key, chain_id) }
    let(:message_hash) { "a" * 32 } # 32-byte binary string

    it "signs a message hash and returns a signature" do
      signature = signer.sign(message_hash)

      expect(signature).to be_a(String)
      expect(signature).to start_with("0x")
    end

    it "returns the same signature for the same message hash" do
      sig1 = signer.sign(message_hash)
      sig2 = signer.sign(message_hash)

      expect(sig1).to eq(sig2)
    end

    it "returns different signatures for different message hashes" do
      hash1 = "a" * 32
      hash2 = "b" * 32

      sig1 = signer.sign(hash1)
      sig2 = signer.sign(hash2)

      expect(sig1).not_to eq(sig2)
    end

    it "returns different signatures for different signers with same message" do
      key1 = "0x" + "1" * 64
      key2 = "0x" + "2" * 64

      signer1 = described_class.new(key1, chain_id)
      signer2 = described_class.new(key2, chain_id)

      sig1 = signer1.sign(message_hash)
      sig2 = signer2.sign(message_hash)

      expect(sig1).not_to eq(sig2)
    end
  end

  describe "attribute readers" do
    it "exposes private_key as read-only" do
      signer = described_class.new(valid_private_key, chain_id)

      expect(signer.private_key).to eq(valid_private_key)
      expect { signer.private_key = "new_key" }.to raise_error(NoMethodError)
    end

    it "exposes chain_id as read-only" do
      signer = described_class.new(valid_private_key, chain_id)

      expect(signer.chain_id).to eq(chain_id)
      expect { signer.chain_id = 999 }.to raise_error(NoMethodError)
    end
  end
end
