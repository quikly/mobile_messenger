# MobileMessenger

Non-official MobileMessenger ruby gem.

## Installation


Add this line to your application's Gemfile to install via rubygems.org

    gem 'mobile_messenger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mobile_messenger

## Usage

### Setup Work

``` ruby
require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'mobile_messenger'

# put your own credentials here
username = 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
password = 'yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'

# set up a client to talk to the API
@client = MobileMessenger::Client.new(username, password)

# Send an SMS
@client.send_sms("12345", "5008885555", "Message goes here")
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
