# AstroCalc

A gem providing various utilities for astronomy.

1) Moon phases

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'astro_calc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install astro_calc

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on my project page at https://redmine.mallaby.me 

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

= Astronomical Algorithms

This library implements algorithms from Jean Meeus, <i>Astronomical Algorithms</i>,
2nd English Edition, Willmann-Bell, Inc., Richmond, Virginia, 1999, with corrections
as of June 15, 2005.

Gem astro-algo provides two modules:

* Astro which implements algorithms from the book. (require 'astro-algo')
* LunarYear which implements helper routines for calculating lunar years. (require 'lunaryear')
 
This gem also comes with several command line scripts.
equinox::       prints the date and time of the vernal equinox for the given year.
lunarcalendar:: prints a conversion chart between the customary Gregarian
                calendar and a lunar year beginning with the full moon on or before
                the vernal equinox.
moon_clock.rb:: a Tk GUI application which displays information about the current
                lunation.
moons::         prints the phases of the moon for the given year.

This is a work in progress. Only the algorithms from <i>Astronomical Algorithms</i>
needed to support my hobby in the LunarYear have been implemented. I will add more
algorithms from the book in time.
