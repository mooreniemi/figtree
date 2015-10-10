# Figtree 🌳
## about
A parser and transformer for loading `.ini` files into Ruby dot notation accessible objects. `.ini` is not a standardized format. But the parser and transformer are easy to extend, unlike regex. :) And it's at 97% LOC coverage.

## performance
A typical `.ini` file takes slightly less than 0.02s to be parsed, transformed, and loaded.

## installation
`gem install figtree`

## usage
    require 'figtree'
    config = Figtree.load_config('spec/support/settings.conf')
    config.common.basic_size_limit
    => 26214400
    # also good
    config[:common]["paid_users_size_limit"]
    => 2147483648
    # also also good :)
    config.common[:paid_users_size_limit]
    => 2147483648
    # and overrides? we got overrides
    overridden_config = Figtree.load_config('spec/support/settings.conf', [:production])
    config.ftp.path
    => "/tmp/"
    overridden_config.ftp.path
    => "/srv/var/tmp/"

## development
### installation
`bundle install`

### tests
`rspec spec/`

#### TODO
- change method signature from Module.class_method to just IniConfig.new(IOObject) ?
- change override to be single symbol rather than array (do we ever need multiples?)
- refactor marked TODO listings in files (mostly refactoring to generic in Transformer)
- add more unit test coverage to Transformer
- seems like Parslet doesn't have a `TransformFailed` error format, worth adding one?
