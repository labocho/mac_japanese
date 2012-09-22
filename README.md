# mac_japanese

Convert MacJapanese string to UTF-8 and vice versa.

## Installation

Add this line to your application's Gemfile:

    gem 'mac_japanese'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mac_japanese

## Usage

    require "mac_japanese"
    MacJapanese.to_utf8("\x82\x9F") # => "あ"
    MacJapanese.to_mac_japanese("あ") # => "\x82\x9F"

    # composed character
    # Convert with private using area character for reversible conversion
    thirteen = MacJapanese.to_utf8("\x85\xAB") # => "?XIII"
    MacJapanese.to_mac_japanese(thirteen) # => "\x85\xAB"

    # composed character
    # Convert without private using area character (irreversible conversion)
    thirteen = MacJapanese.to_utf8("\x85\xAB", use_pua: false) # => "XIII"
    MacJapanese.to_mac_japanese(thirteen) # => "XIII"

## Limitation

Ruby 1.8 (or earlier) is not supported.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
