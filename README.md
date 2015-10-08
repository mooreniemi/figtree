# Figtree 🌳
## about
A parser and transformer for loading `.ini` files into Ruby dot notation accessible objects. `.ini` is not a standardized format. But the parser and transformer are easy to extend, unlike regex. :) And it's at 96% LOC coverage.

## performance
A typical `.ini` file takes slightly less than 0.02s to be parsed, transformed, and loaded.

## installation
`gem install figtree`

## usage
    require 'figtree'
    config = Figtree.load_config('spec/support/settings.conf')
    config.common.basic_size_limit
    => 26214400

# development
## installation
`bundle install`

## tests
`rspec spec/`

### TODO
- refactor marked TODO listings in files (mostly refactoring to generic)
- add more unit test coverage to Transformer
- seems like Parslet doesn't have a `TransformFailed` error format, worth adding one?
