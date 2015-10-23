                  %%%,%%%%%%%
                   ,'%% \\-*%%%%%%%
             ;%%%%%*%   _%%%%"
              ,%%%       \(_.*%%%%.
              % *%%, ,%%%%*(    '
            %^     ,*%%% )\|,%%*%,_
                 *%    \/ #).-"*%%*
                     _.) ,/ *%,
             _________/)#(_____________
#### art by [b'ger](http://ascii.co.uk/art/tree)

# Figtree
## about
A parser and transformer for loading `.ini` files into Ruby dot notation accessible objects. `.ini` is not a standardized format. But the parser and transformer are easy to extend. The goal of figtree is not to accept all `.ini` files generously, but more strictly define `.ini` files so we can make smarter guesses about how to covert your settings into objects.

If the `.ini` file is invalid, an error will be raised, with the line and char position of the error. If you extend this gem to have more rules, and one of those rules fails to transform, you will have an error raised.

## alternatives
If you want an industrial strength, pure Ruby solution, check out [inifile gem](https://github.com/TwP/inifile). It is much more generous about what it accepts as valid `.ini` files, and with no pesky dependencies!

## disambiguation
Looking for the graphical viewer of phyllogenic trees? You want this other [Figtree](http://tree.bio.ed.ac.uk/software/figtree/).

## performance
A typical `.ini` file takes slightly less than 0.02s to be parsed, transformed, and loaded. Currently, the whole `.ini` file is read into memory at once. The assumption being these files should not typically be too big. But future minor versions might move to line by line ingestion.

## installation
`gem install figtree`

## usage
    require 'figtree'
    config = Figtree::IniConfig.new('spec/support/settings.conf')
    config.common.basic_size_limit
    => 26214400
    # also good
    config[:common]["paid_users_size_limit"]
    => 2147483648
    # also also good :)
    config.common[:paid_users_size_limit]
    => 2147483648
    # and overrides? we got overrides
    overridden_config = Figtree::IniConfig.new('spec/support/settings.conf', :production)
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
- move way from needing to parse whole file at once? (move to `IO.foreach` ?)
- give char/line position of transformer failures
- refactor marked TODO listings in files (mostly refactoring to generic in Transformer)
