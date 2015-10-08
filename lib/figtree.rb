require 'figtree/parser'
require 'figtree/transformer'
require 'figtree/ini_config'

module Figtree
  def self.load_config(file_path, overrides=[])
    parsed_subgroups = figgy_transform(
      figgy_parse(
        File.read(file_path)
      ),
      overrides
    )
    IniConfig.new(
      parsed_subgroups.reduce({}, :merge!)
    )
  end

  private
  def self.figgy_parse(str)
    Parser.new.parse(str)
  rescue Parslet::ParseFailed => failure
    puts failure.cause.ascii_tree
  end

  def self.figgy_transform(tree, overrides = [])
    Transformer.new.apply(tree, overrides: overrides)
  rescue
    puts 'failed transform'
    {} # returning hash just to preserve stack trace
  end
end
