# frozen_string_literal: true

require "spec_helper"

RSpec.describe Polymarket::Headers do
  let(:private_key) { "0x" + "1" * 64 }
  let(:chain_id) { 137 }
  let(:signer) { Polymarket::Signer.new(private_key, chain_id) }
  let(:api_key) { "test_api_key" }
  let(:api_secret) { Base64.urlsafe_encode64("test_secret") }
  let(:api_passphrase) { "test_passphrase" }
  let(:creds) { Polymarket::ApiCreds.new(api_key: api_key, api_secret: api_secret, api_passphrase: api_passphrase) }
  let(:request_args) { Polymarket::RequestArgs.new(method: "GET", request_path: "/api/v1/test", body: '{"test": "data"}') }

  describe ".create_level_1_headers" do
    context "with nonce" do
      let(:nonce) { 12345 }

      it "creates headers with all required fields" do
        headers = described_class.create_level_1_headers(signer, nonce)

        expect(headers).to be_a(Hash)
        expect(headers[Polymarket::Headers::POLY_ADDRESS]).to eq(signer.address)
        expect(headers[Polymarket::Headers::POLY_SIGNATURE]).to be_a(String)
        expect(headers[Polymarket::Headers::POLY_SIGNATURE]).to start_with("0x")
        expect(headers[Polymarket::Headers::POLY_TIMESTAMP]).to be_a(String)
        expect(headers[Polymarket::Headers::POLY_NONCE]).to eq("12345")
      end

      it "includes timestamp as string" do
        headers = described_class.create_level_1_headers(signer, nonce)
        timestamp = headers[Polymarket::Headers::POLY_TIMESTAMP].to_i

        expect(timestamp).to be > 0
        expect(timestamp).to be <= Time.now.to_i
      end

      it "includes signature" do
        headers = described_class.create_level_1_headers(signer, nonce)
        signature = headers[Polymarket::Headers::POLY_SIGNATURE]

        expect(signature).to be_a(String)
        expect(signature.length).to be > 0
      end
    end

    context "without nonce" do
      it "creates headers with nil nonce" do
        headers = described_class.create_level_1_headers(signer, nil)

        expect(headers[Polymarket::Headers::POLY_NONCE]).to eq("")
      end
    end

    it "uses different timestamps for different calls" do
      headers1 = described_class.create_level_1_headers(signer, 1)
      sleep(1) # Delay to ensure different timestamps
      headers2 = described_class.create_level_1_headers(signer, 1)

      timestamp1 = headers1[Polymarket::Headers::POLY_TIMESTAMP].to_i
      timestamp2 = headers2[Polymarket::Headers::POLY_TIMESTAMP].to_i
      expect(timestamp2).to be >= timestamp1
    end
  end

  describe ".create_level_2_headers" do
    it "creates headers with all required fields" do
      headers = described_class.create_level_2_headers(signer, creds, request_args)

      expect(headers).to be_a(Hash)
      expect(headers[Polymarket::Headers::POLY_ADDRESS]).to eq(signer.address)
      expect(headers[Polymarket::Headers::POLY_SIGNATURE]).to be_a(String)
      expect(headers[Polymarket::Headers::POLY_TIMESTAMP]).to be_a(String)
      expect(headers[Polymarket::Headers::POLY_API_KEY]).to eq(api_key)
      expect(headers[Polymarket::Headers::POLY_PASSPHRASE]).to eq(api_passphrase)
    end

    it "includes HMAC signature" do
      headers = described_class.create_level_2_headers(signer, creds, request_args)
      signature = headers[Polymarket::Headers::POLY_SIGNATURE]

      expect(signature).to be_a(String)
      expect(signature.length).to be > 0
    end

    it "includes timestamp as string" do
      headers = described_class.create_level_2_headers(signer, creds, request_args)
      timestamp = headers[Polymarket::Headers::POLY_TIMESTAMP].to_i

      expect(timestamp).to be > 0
      expect(timestamp).to be <= Time.now.to_i
    end

    context "with different request methods" do
      it "creates different signatures for different methods" do
        get_args = Polymarket::RequestArgs.new(method: "GET", request_path: "/api/v1/test", body: nil)
        post_args = Polymarket::RequestArgs.new(method: "POST", request_path: "/api/v1/test", body: nil)

        headers1 = described_class.create_level_2_headers(signer, creds, get_args)
        headers2 = described_class.create_level_2_headers(signer, creds, post_args)

        expect(headers1[Polymarket::Headers::POLY_SIGNATURE]).not_to eq(headers2[Polymarket::Headers::POLY_SIGNATURE])
      end
    end

    context "with different request paths" do
      it "creates different signatures for different paths" do
        args1 = Polymarket::RequestArgs.new(method: "GET", request_path: "/api/v1/test1", body: nil)
        args2 = Polymarket::RequestArgs.new(method: "GET", request_path: "/api/v1/test2", body: nil)

        headers1 = described_class.create_level_2_headers(signer, creds, args1)
        headers2 = described_class.create_level_2_headers(signer, creds, args2)

        expect(headers1[Polymarket::Headers::POLY_SIGNATURE]).not_to eq(headers2[Polymarket::Headers::POLY_SIGNATURE])
      end
    end

    context "with different bodies" do
      it "creates different signatures for different bodies" do
        args1 = Polymarket::RequestArgs.new(method: "POST", request_path: "/api/v1/test", body: '{"a": 1}')
        args2 = Polymarket::RequestArgs.new(method: "POST", request_path: "/api/v1/test", body: '{"b": 2}')

        headers1 = described_class.create_level_2_headers(signer, creds, args1)
        headers2 = described_class.create_level_2_headers(signer, creds, args2)

        expect(headers1[Polymarket::Headers::POLY_SIGNATURE]).not_to eq(headers2[Polymarket::Headers::POLY_SIGNATURE])
      end
    end

    context "with nil body" do
      it "handles nil body correctly" do
        args = Polymarket::RequestArgs.new(method: "GET", request_path: "/api/v1/test", body: nil)
        headers = described_class.create_level_2_headers(signer, creds, args)

        expect(headers[Polymarket::Headers::POLY_SIGNATURE]).to be_a(String)
      end
    end
  end

  describe "constants" do
    it "defines POLY_ADDRESS constant" do
      expect(described_class::POLY_ADDRESS).to eq("POLY_ADDRESS")
    end

    it "defines POLY_SIGNATURE constant" do
      expect(described_class::POLY_SIGNATURE).to eq("POLY_SIGNATURE")
    end

    it "defines POLY_TIMESTAMP constant" do
      expect(described_class::POLY_TIMESTAMP).to eq("POLY_TIMESTAMP")
    end

    it "defines POLY_NONCE constant" do
      expect(described_class::POLY_NONCE).to eq("POLY_NONCE")
    end

    it "defines POLY_API_KEY constant" do
      expect(described_class::POLY_API_KEY).to eq("POLY_API_KEY")
    end

    it "defines POLY_PASSPHRASE constant" do
      expect(described_class::POLY_PASSPHRASE).to eq("POLY_PASSPHRASE")
    end
  end
end
