# Public Suffix List

<tt>PublicSuffix</tt> is a Ruby domain name parser based on the [Public Suffix List](http://publicsuffix.org/).

[![Build Status](https://secure.travis-ci.org/weppos/publicsuffix-ruby.png)](http://travis-ci.org/weppos/publicsuffix-ruby)


## What is the Public Suffix List?

The Public Suffix List is a cross-vendor initiative to provide an accurate list of domain name suffixes.

The Public Suffix List is an initiative of the Mozilla Project, but is maintained as a community resource. It is available for use in any software, but was originally created to meet the needs of browser manufacturers.

A "public suffix" is one under which Internet users can directly register names. Some examples of public suffixes are ".com", ".co.uk" and "pvt.k12.wy.us". The Public Suffix List is a list of all known public suffixes.

Source: http://publicsuffix.org


## Why the Public Suffix List is better than any available Regular Expression parser?

Previously, browsers used an algorithm which basically only denied setting wide-ranging cookies for top-level domains with no dots (e.g. com or org). However, this did not work for top-level domains where only third-level registrations are allowed (e.g. co.uk). In these cases, websites could set a cookie for co.uk which will be passed onto every website registered under co.uk.

Clearly, this was a security risk as it allowed websites other than the one setting the cookie to read it, and therefore potentially extract sensitive information.

Since there is no algorithmic method of finding the highest level at which a domain may be registered for a particular top-level domain (the policies differ with each registry), the only method is to create a list of all top-level domains and the level at which domains can be registered. This is the aim of the effective TLD list.

As well as being used to prevent cookies from being set where they shouldn't be, the list can also potentially be used for other applications where the registry controlled and privately controlled parts of a domain name need to be known, for example when grouping by top-level domains.

Source: https://wiki.mozilla.org/Public_Suffix_List

Not convinced yet? Check out [this real world example](http://stackoverflow.com/q/288810/123527).


## Requirements

- Ruby >= 2.0

For an older versions of Ruby use a previous release. We also support several [Ruby implementations](http://simonecarletti.com/code/publicsuffix/#implementations).


## Installation

The best way to install *PublicSuffix* is via [RubyGems](https://rubygems.org/).

    $ gem install public_suffix

You might need administrator privileges on your system to install the gem.


## Basic Usage

Example domain without subdomains.

```ruby
domain = PublicSuffix.parse("google.com")
# => #<PublicSuffix::Domain>
domain.tld
# => "com"
domain.sld
# => "google"
domain.trd
# => nil
domain.domain
# => "google.com"
domain.subdomain
# => nil
```

Example domain with subdomains.

```ruby
domain = PublicSuffix.parse("www.google.com")
# => #<PublicSuffix::Domain>
domain.tld
# => "com"
domain.sld
# => "google"
domain.trd
# => "www"
domain.domain
# => "google.com"
domain.subdomain
# => "www.google.com"
```

Simple validation example.

```ruby
PublicSuffix.valid?("google.com")
# => true

PublicSuffix.valid?("www.google.com")
# => true

PublicSuffix.valid?("x.yz")
# => false
```

## Fully Qualified Domain Names

This library automatically recognizes Fully Qualified Domain Names. A FQDN is a domain name that end with a trailing dot.

```ruby
# Parse a standard domain name
domain = PublicSuffix.parse("www.google.com")
# => #<PublicSuffix::Domain>
domain.tld
# => "com"

# Parse a fully qualified domain name
domain = PublicSuffix.parse("www.google.com.")
# => #<PublicSuffix::Domain>
domain.tld
# => "com"
```

## Private domains

This library has support for switching off support for private (non-ICANN) domains

```ruby
# Parse a domain on a private TLD
domain = PublicSuffix.parse("something.blogspot.com")
# => #<PublicSuffix::Domain>
domain.tld
# => "blogspot.com"

# Disable support for private TLDs
PublicSuffix::List.private_domains = false
# => #<PublicSuffix::List>
domain = PublicSuffix.parse("something.blogspot.com")
# => #<PublicSuffix::Domain>
domain.tld
# => "com"
```

## Feedback and bug reports

If you use this library and find yourself missing any functionality, please [let me know](mailto:weppos@weppos.net).

Pull requests are very welcome! Please include tests and/or feature coverage for every patch, and create a topic branch for every separate change you make.

Report issues or feature requests to [GitHub Issues](https://github.com/weppos/publicsuffix-ruby/issues).


## More

* [Homepage](http://simonecarletti.com/code/publicsuffix)
* [Repository](https://github.com/weppos/publicsuffix-ruby)
* [API Documentation](http://rubydoc.info/gems/public_suffix)
* [Introducing the Public Suffix List library for Ruby](http://simonecarletti.com/blog/2010/06/public-suffix-list-library-for-ruby/)


## Changelog

See the [CHANGELOG.md](CHANGELOG.md) file for details.


## License

Copyright (c) 2009-2015 Simone Carletti. This is Free Software distributed under the MIT license.
