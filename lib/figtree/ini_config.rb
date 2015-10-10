require 'ostruct'
module Figtree
  class IniConfig < OpenStruct
    def initialize(file_path, overrides = [])
      if !file_path.is_a?(String)
        parsed_subgroups = file_path
      else
        parsed_subgroups = figgy_transform(
          figgy_parse(
            File.read(file_path)
          ),
          overrides
        )
      end
      super(
        parsed_subgroups.reduce({}, :merge!)
      )
    end

    private
    def figgy_parse(str)
      Parser.new.parse(str)
    rescue Parslet::ParseFailed => failure
      STDERR.puts "\nInvalid ini file.\n" +
        "Error: #{failure.cause.ascii_tree}" +
        "Please correct the file and retry."
        raise
    end

    def figgy_transform(tree, overrides = [])
      Transformer.new.apply(tree, overrides: overrides)
    rescue => e
      STDERR.puts "\nInvalid transformation rule.\n" +
        "Error: #{e}" +
        "Please correct your transformer rule and retry."
        raise TransformFailed
    end
  end

  class Subgroup < OpenStruct
  end

  class TransformFailed < Exception
  end
end
