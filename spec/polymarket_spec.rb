# frozen_string_literal: true

require "polymarket"

RSpec.describe Polymarket do
  it "has a version number" do
    expect(Polymarket::VERSION).not_to be nil
  end

  describe "Client" do
    let(:host) { "https://clob.polymarket.com" }
    let(:chain_id) { 1 }
    let(:private_key) { ENV.fetch("PRIVATE_KEY", "") }
    let(:client) { Polymarket::Client.new(host: host, chain_id: chain_id, key: private_key) }

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
        allow(client).to receive(:get_tick_size).and_return("0.1")
        allow(client).to receive(:get_neg_risk).and_return(false)
        
        # Mock the builder
        mock_builder = double("OrderBuilder")
        allow(mock_builder).to receive(:create_order).and_return({ order: "data" })
        client.instance_variable_set(:@builder, mock_builder)
        
        result = client.create_order(order_args)
        expect(result).to eq({ order: "data" })
      end

      it "raises error for invalid price" do
        allow(client).to receive(:get_tick_size).and_return("0.1")
        
        order_args.price = 0.05  # Invalid price for tick size 0.1
        
        expect { client.create_order(order_args) }.to raise_error(ArgumentError, /Price.*is not valid for tick size/)
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
        allow(client).to receive(:get_tick_size).and_return("0.1")
        allow(client).to receive(:get_neg_risk).and_return(false)
        
        # Mock the price response
        mock_response = double("Net::HTTPSuccess")
        allow(mock_response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
        allow(mock_response).to receive(:body).and_return('{"price": 0.5}')
        allow(client).to receive(:get_price).and_return(mock_response)
        
        # Mock the builder
        mock_builder = double("OrderBuilder")
        allow(mock_builder).to receive(:create_market_order).and_return({ order: "data" })
        client.instance_variable_set(:@builder, mock_builder)
        
        result = client.create_market_order(order_args)
        expect(result).to eq({ order: "data" })
      end
    end
  end
end
