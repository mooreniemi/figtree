require 'ostruct'
module Figtree
  class IniConfig < OpenStruct
    def initialize(ini, override = :none)
      # cheat to allow a parsed hash in
      if ini.is_a?(Hash)
        parsed_subgroups = ini
      else
        parsed_subgroups = figgy_transform(
          figgy_parse(
            File.read(ini)
          ),
          override
        ).reduce({}, :merge!)
      end
      super(
        parsed_subgroups
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

    def figgy_transform(tree, override)
      Transformer.new.apply(tree, override: override)
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
