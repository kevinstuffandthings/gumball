# Gumball [![Build Status](https://travis-ci.com/kevinstuffandthings/gumball.svg?branch=master)](https://travis-ci.com/kevinstuffandthings/gumball) [![Gem Version](https://badge.fury.io/rb/gumball.svg)](https://badge.fury.io/rb/gumball)

A gem providing a mechanism to dispense instances of a class, somewhere between a true singleton and new instance each time.

Originally developed for [Simulmedia](https://simulmedia.com).

## Installation
Add this line to your application's Gemfile:

```ruby
# update with the version of your choice
gem 'gumball'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install gumball
```

## Usage
Let's say we have some expensive operation we need to utilize the value of. We need to refresh it occasionally, but if we sometimes get a
slightly-stale copy, that's ok.

```ruby
class ExpensiveThing
  def self.value
    sleep 5
    rand(1..100)
  end
end
```

We set up a new dispenser for that operation. These dispensers are best saved as class variables, so the dispenser itself is a singleton.

```ruby
require 'gumball'

dispenser = Gumball::Dispenser.new(300) { ExpensiveThing.value }
# => #<Gumball::Dispenser:0x007f87eff446c8 @ttl=300, @last_refreshed=nil, @refresh_block=#<Proc:0x007f87eff44678@(irb):9>, @on_change_block=nil>

dispenser.item # this will take a while
# => 90

dispenser.item # if run in quick succession, returned result is immediate, and value is the same
# => 90

sleep 305

dispenser.item # ttl has expired... prepare to wait
# => 41

dispenser.item # we've saved our refreshed version, and our response is immediate!
# => 41
```

If we want to be able to set up our dispenser so that we can perform some other operation in the event the value actually changes:

```ruby
dispenser = Gumball::Dispenser.new(300) { ExpensiveThing.value }
dispenser.on_change { |o, n| puts "OUR VALUE CHANGED: #{o} -> #{n}" }
```

The `on_change` method counts on equality being properly implemented between the values, and ONLY fires when inequality between
old and new items is detected. If the refresh pulls in the same value, the `on_change` block is not triggered.

# Problems?
Please submit an [issue](https://github.com/kevinstuffandthings/gumball/issues).
We'll figure out how to get you up and running with Gumball as smoothly as possible.
