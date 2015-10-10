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
    STDERR.puts "\nInvalid ini file.\n" +
      "Error: #{failure.cause.ascii_tree}" +
      "Please correct the file and retry."
      raise
  end

  def self.figgy_transform(tree, overrides = [])
    Transformer.new.apply(tree, overrides: overrides)
  rescue => e
    STDERR.puts "\nInvalid transformation rule.\n" +
      "Error: #{e}" +
      "Please correct your transformer rule and retry."
    raise TransformFailed
  end

  class TransformFailed < Exception
  end
end
