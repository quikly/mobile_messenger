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
require 'mobile-messenger'

# put your own credentials here
username = 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
password = 'yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'

# set up a client to talk to the Twilio REST API
@client = MobileMessenger::REST::Client.new username, password
```

### Send an SMS

``` ruby
# send an sms
@client.account.sms.messages.create(
  :from => '+14159341234',
  :to => '+16105557069',
  :body => 'Hey there!'
)
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
