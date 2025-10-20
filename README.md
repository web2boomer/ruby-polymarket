# Polymarket gem

Ruby client for Polymarket, including the CLOB, Gamma and Data APIs. 

Full API documentation can be found [here](https://docs.polymarket.com/quickstart/introduction/main). 

It's a work in progress, not every end point is tested. 


### Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add 'ruby-polymarket'

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install 'ruby-polymarket'



### Basic Setup

First, require the gem and initialize clients:

```ruby
require 'polymarket'

# Initialize CLOB client for trading operations
clob_client = Polymarket::CLOBClient.new(
  clob_host: 'https://clob.polymarket.com',  # Production
  # clob_host: 'https://clob-staging.polymarket.com',  # Staging
  chain_id: Polymarket::Constants::POLYGON  # 137 for Polygon mainnet
)

# Initialize Gamma client for market data (no parameters required)
gamma_client = Polymarket::GammaClient.new

# Initialize Data client for data API (no parameters required)
data_client = Polymarket::DataClient.new

# Or use convenience methods
clob_client = Polymarket.clob_client(chain_id: Polymarket::Constants::POLYGON)
gamma_client = Polymarket.gamma_client
data_client = Polymarket.data_client
```




## Gamma Client - Data API

The Gamma client provides access to market data without requiring authentication:

```ruby
# Initialize Gamma client (no parameters required)
gamma_client = Polymarket::GammaClient.new

# Get all markets
markets = gamma_client.get_markets
puts "Available markets: #{markets}"

# Get specific market details
market_id = "0x1234567890abcdef..."  # Replace with actual market ID
market = gamma_client.get_market(market_id)
puts "Market details: #{market}"

# Get market activity
activity = gamma_client.get_market_activity(market_id)
puts "Market activity: #{activity}"

# Get market trades
trades = gamma_client.get_market_trades(market_id)
puts "Market trades: #{trades}"

# Get market stats
stats = gamma_client.get_market_stats(market_id)
puts "Market stats: #{stats}"
```



## Data Client - Data API

The Data client provides access to comprehensive market and event data without requiring authentication:

```ruby
# Initialize Data client (no parameters required)
data_client = Polymarket::DataClient.new

# Get all markets
markets = data_client.get_markets
puts "Available markets: #{markets}"

# Get specific market details
market_id = "0x1234567890abcdef..."  # Replace with actual market ID
market = data_client.get_market(market_id)
puts "Market details: #{market}"

# Get market activity
activity = data_client.get_market_activity(market_id)
puts "Market activity: #{activity}"

# Get market trades
trades = data_client.get_market_trades(market_id)
puts "Market trades: #{trades}"

# Get market stats
stats = data_client.get_market_stats(market_id)
puts "Market stats: #{stats}"

# Get all events
events = data_client.get_events
puts "Available events: #{events}"

# Get specific event details
event_id = "0xabcdef1234567890..."  # Replace with actual event ID
event = data_client.get_event(event_id)
puts "Event details: #{event}"

# Get event activity
event_activity = data_client.get_event_activity(event_id)
puts "Event activity: #{event_activity}"

# Get activity with optional parameters
activity = data_client.get_activity(
  user: "0x1234567890abcdef...",  # Optional: filter by user
  market: "0xabcdef1234567890...", # Optional: filter by market
  limit: 50,                       # Optional: limit results
  offset: 0                        # Optional: pagination offset
)
puts "Activity: #{activity}"
```

## CLOB client

### Allowances

See guidance on [py-polymarket](https://github.com/Polymarket/py-polymarket).

### Usage

Below is a comprehensive usage guide for the Polymarket gem. This client supports both Level 1 (private key) and Level 2 (API credentials) authentication modes.



#### Authentication (CLOB Client)

The CLOB client supports two authentication levels:

**Level 1 Authentication (Private Key)**
```ruby
# Initialize with private key for Level 1 auth
clob_client = Polymarket::CLOBClient.new(
  clob_host: 'https://clob.polymarket.com',
  chain_id: Polymarket::Constants::POLYGON,
  key: 'your_private_key_here'  # 0x-prefixed private key
)

# Get your wallet address
address = clob_client.get_address
puts "Wallet address: #{address}"
```

**Level 2 Authentication (API Credentials)**
```ruby
# Create API credentials (requires Level 1 auth first)
creds = clob_client.create_api_key
puts Polymarket::Constants::CREDENTIAL_CREATION_WARNING
puts "API Key: #{creds.api_key}"
puts "Secret: #{creds.api_secret}"
puts "Passphrase: #{creds.api_passphrase}"

# Set credentials for Level 2 auth
clob_client.set_api_creds(creds)
```

#### Market Data

**CLOB Client - Trading Data**
Get market information and pricing data:

```ruby
# Get all markets
markets = clob_client.get_markets
puts "Available markets: #{markets}"

# Get order book for a specific token
order_book = clob_client.get_order_book(token_id)
puts "Order book: #{order_book}"

# Get current price for a token
price_response = clob_client.get_price(token_id, "BUY")
puts "Current buy price: #{price_response.body}"

# Get spread information
spread_response = clob_client.get_spread(token_id)
puts "Spread: #{spread_response.body}"
```

#### Placing Orders

**Limit Orders**
```ruby
# Create order arguments
order_args = Polymarket::OrderArgs.new(
  token_id: "0x1234567890abcdef...",  # Token ID
  price: 0.65,                        # Price in USD
  size: 100,                          # Size in token units
  side: "BUY",                        # "BUY" or "SELL"
  fee_rate_bps: 0,                    # Fee rate in basis points
  nonce: Time.now.to_i,               # Nonce for order uniqueness
  expiration: Time.now.to_i + 3600    # Expiration timestamp
)

# Create and post the order
order = clob_client.create_and_post_order(order_args)
puts "Order created: #{order}"
```

**Market Orders**
```ruby
# Create market order arguments
market_order_args = Polymarket::MarketOrderArgs.new(
  token_id: "0x1234567890abcdef...",
  amount: 100,                        # Amount in USD
  side: "BUY",
  order_type: Polymarket::OrderType::FOK  # Fill or Kill
)

# Create and post market order
market_order = clob_client.create_and_post_order(market_order_args)
puts "Market order created: #{market_order}"
```

#### Order Management

```ruby
# Get your open orders
orders = clob_client.get_orders
puts "Open orders: #{orders}"

# Get specific order details
order_id = "your_order_id"
order_details = clob_client.get_order(order_id)
puts "Order details: #{order_details}"

# Cancel a specific order
cancel_response = clob_client.cancel(order_id)
puts "Cancel response: #{cancel_response}"

# Cancel all orders
cancel_all_response = clob_client.cancel_all
puts "Cancel all response: #{cancel_all_response}"
```



#### Balance and Allowances

```ruby
# Check balance and allowance (requires Level 2 auth)
# Note: This feature is currently under development
balance = clob_client.get_balance_allowance
puts "Balance and allowance: #{balance}"

# Update allowance (requires Level 2 auth)
# Note: This feature is currently under development
update_response = clob_client.update_balance_allowance
puts "Allowance update: #{update_response}"
```

#### Complete Example

Here's a complete example showing how to place a limit order:

```ruby
require 'polymarket'

# Initialize client with private key
client = Polymarket::Client.new(
  clob_host: 'https://clob.polymarket.com',
  chain_id: Polymarket::Constants::POLYGON,
  key: 'your_private_key_here'
)

# Get market data
token_id = "0x1234567890abcdef..."  # Replace with actual token ID
order_book = clob_client.get_order_book(token_id)
puts "Order book retrieved"

# Place a limit order
order_args = Polymarket::OrderArgs.new(
  token_id: token_id,
  price: 0.65,
  size: 100,
  side: "BUY",
  fee_rate_bps: 0,
  nonce: Time.now.to_i,
  expiration: Time.now.to_i + 3600
)

order = clob_client.create_and_post_order(order_args)
puts "Order placed successfully: #{order}"

# Monitor the order
sleep(5)
orders = clob_client.get_orders
puts "Current orders: #{orders}"
```

#### Error Handling

The client includes comprehensive error handling:

```ruby
begin
  order = clob_client.create_and_post_order(order_args)
  puts "Order successful: #{order}"
rescue Polymarket::Error => e
  puts "CLOB error: #{e.message}"
rescue StandardError => e
  puts "Unexpected error: #{e.message}"
end
```

#### Important Notes

1. **Token Allowances**: Ensure proper token allowances are set before trading (see Requisites section above)
2. **Network Selection**: Use appropriate `chain_id` for your target network (Polygon mainnet or Amoy testnet)
3. **Rate Limiting**: Be mindful of API rate limits when making multiple requests
4. **Order Expiration**: Always set appropriate expiration times for your orders
5. **Security**: Keep your private keys and API credentials secure
6. **Development Status**: This gem is currently in development. Some features may be incomplete or subject to change


#### Trading History

```ruby
# Get your trade history
trades = clob_client.get_trades
puts "Trade history: #{trades}"

# Get last trade price for a token
last_trade = clob_client.get_last_trade_price(token_id)
puts "Last trade price: #{last_trade.body}"
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## With all that done... Wen Lambo?