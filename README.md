## Figtree
A parser and transformer for loading `.ini` files into Ruby dot notation accessible objects.

A typical `.ini` file takes slightly less than 0.02 to be parsed, transformed, and loaded.

# installation
`bundle install`

# tests
`rspec spec/`

# TODO
- refactor marked TODO listings in files (mostly refactoring to generic)
- allow indifferent access? (not just dot notation but allow hash access)
- add more unit test coverage to Transformer
- seems like Parslet doesn't have a `TransformFailed` error format, worth adding one?
