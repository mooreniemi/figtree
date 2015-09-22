## Figtree
A parser and transformer for loading `.ini` files into Ruby dot notation accessible objects.

# installation
`bundle install`

# tests
`rspec spec/`

# TODO
- refactor marked TODO listings in files (mostly refactoring to generic)
- break `figtree.rb` file into several files
- rearrange files into gem structure
- benchmark tests (not just `rspec --profile`)
- allow indifferent access? (not just dot notation but allow hash access)
- add more unit test coverage to Transformer
- seems like Parslet doesn't have a `TransformFailed` error format, worth adding one?
