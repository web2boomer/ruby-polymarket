# frozen_string_literal: true

require "polymarket"

RSpec.describe Polymarket do
  it "has a version number" do
    expect(Polymarket::VERSION).not_to be nil
  end

  describe "CLOBClient" do
    let(:clob_host) { "https://clob.polymarket.com" }
    let(:chain_id) { 1 }
    # Use a valid 32-byte hex private key (64 hex chars = 32 bytes)
    let(:private_key) { ENV.fetch("PRIVATE_KEY", "0x" + "1" * 64) }
    let(:clob_client) { Polymarket::CLOBClient.new(clob_host: clob_host, chain_id: chain_id, key: private_key) }

    describe "#create_order" do
      let(:order_args) do
        Polymarket::OrderArgs.new(
          token_id: "",
          price: 0.5,
          size: 100,
          side: "BUY",
          fee_rate_bps: 10,
          nonce: 12345,
          expiration: 1234567890,
          taker: "0x0000000000000000000000000000000000000000"
        )
      end

      it "creates an order with proper validation" do
        # Mock the tick_size and neg_risk methods
        allow(clob_client).to receive(:get_tick_size).and_return("0.1")
        allow(clob_client).to receive(:get_neg_risk).and_return(false)
        
        # Mock the builder
        mock_builder = double("OrderBuilder")
        allow(mock_builder).to receive(:create_order).and_return({ order: "data" })
        clob_client.instance_variable_set(:@builder, mock_builder)
        
        result = clob_client.create_order(order_args)
        expect(result).to eq({ order: "data" })
      end

      it "raises error for invalid price" do
        allow(clob_client).to receive(:get_tick_size).and_return("0.1")
        
        order_args.price = 0.05  # Invalid price for tick size 0.1
        
        expect { clob_client.create_order(order_args) }.to raise_error(ArgumentError, /Price.*is not valid for tick size/)
      end
    end

    describe "#create_market_order" do
      let(:order_args) do
        Polymarket::MarketOrderArgs.new(
          token_id: "0x1234567890123456789012345678901234567890",
          amount: 100,
          side: "BUY",
          price: nil,  # Will be fetched from market
          fee_rate_bps: 10,
          nonce: 12345,
          taker: "0x0000000000000000000000000000000000000000",
          order_type: Polymarket::OrderType::FOK
        )
      end

      it "creates a market order with price fetching" do
        # Mock the tick_size and neg_risk methods
        allow(clob_client).to receive(:get_tick_size).and_return("0.1")
        allow(clob_client).to receive(:get_neg_risk).and_return(false)
        
        # Mock the price response
        mock_response = double("Net::HTTPSuccess")
        allow(mock_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(mock_response).to receive(:body).and_return('{"price": 0.5}')
        allow(clob_client).to receive(:get_price).and_return(mock_response)
        
        # Mock the builder
        mock_builder = double("OrderBuilder")
        allow(mock_builder).to receive(:create_market_order).and_return({ order: "data" })
        clob_client.instance_variable_set(:@builder, mock_builder)
        
        result = clob_client.create_market_order(order_args)
        expect(result).to eq({ order: "data" })
      end
    end
  end

  describe "GammaClient" do
    let(:gamma_client) { Polymarket::GammaClient.new }

    it "initializes without parameters" do
      expect(gamma_client).to be_a(Polymarket::GammaClient)
      expect(gamma_client.gamma_host).to eq("https://gamma-api.polymarket.com")
    end

    it "can be created with custom host" do
      custom_client = Polymarket::GammaClient.new(gamma_host: "https://custom-gamma.polymarket.com")
      expect(custom_client.gamma_host).to eq("https://custom-gamma.polymarket.com")
    end

    describe "convenience methods" do
      it "can be created via Polymarket.gamma_client" do
        client = Polymarket.gamma_client
        expect(client).to be_a(Polymarket::GammaClient)
      end
    end
  end

  describe "DataClient" do
    let(:data_client) { Polymarket::DataClient.new }

    it "initializes without parameters" do
      expect(data_client).to be_a(Polymarket::DataClient)
      expect(data_client.data_host).to eq("https://data-api.polymarket.com")
    end

    it "can be created with custom host" do
      custom_client = Polymarket::DataClient.new(data_host: "https://custom-data.polymarket.com")
      expect(custom_client.data_host).to eq("https://custom-data.polymarket.com")
    end

    describe "convenience methods" do
      it "can be created via Polymarket.data_client" do
        client = Polymarket.data_client
        expect(client).to be_a(Polymarket::DataClient)
      end
    end
  end

  describe "convenience methods" do
    it "can create CLOB client via Polymarket.clob_client" do
      client = Polymarket.clob_client(chain_id: 1)
      expect(client).to be_a(Polymarket::CLOBClient)
    end

    it "can create Gamma client via Polymarket.gamma_client" do
      client = Polymarket.gamma_client
      expect(client).to be_a(Polymarket::GammaClient)
    end

    it "can create Data client via Polymarket.data_client" do
      client = Polymarket.data_client
      expect(client).to be_a(Polymarket::DataClient)
    end
  end
end
