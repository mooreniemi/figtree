require 'ostruct'
module Figtree
  class IniConfig < OpenStruct
    def initialize(ini, override = :none)
      # cheat to allow a parsed hash in
      parsed_subgroups = ini.is_a?(Hash) ?
        ini : subgroups_from(ini, override)
      super(parsed_subgroups)
    end

    private
    def subgroups_from(ini_file, override)
      figgy_transform(
        figgy_parse(
          File.read(ini_file)
        ),
        override
      ).reduce({}, :merge!)
    end

    def figgy_parse(str)
      Parser.new.parse(str)
      # argument error is invalid byte sequence
    rescue Parslet::ParseFailed, ArgumentError => failure
      puts failure
      if failure.class == Parslet::ParseFailed
        failure = failure.cause.ascii_tree
      end
      STDERR.puts "\nInvalid ini file.\n" +
        "Error: #{failure}" +
        "Please correct the file and retry."
        raise
    end

    def figgy_transform(tree, override)
      Transformer.new.apply(tree, override: override)
    rescue => e
      puts e
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
