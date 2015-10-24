require 'parslet'
require 'ostruct'
require 'ipaddr'
require 'wannabe_bool'

module Figtree
  # a transformer takes a parsed, valid AST and applies rules, usually
  # in a context free manner
  class Transformer < Parslet::Transform
    rule(:snake_case_key => simple(:key), :number => simple(:value)) do
      {
        key.to_sym => Integer(value)
      }
    end
    rule(:snake_case_key => simple(:key), :string => subtree(:value)) do
      merged_string =
        case value
        when Hash
          value[:right]
        when Array
          value.inject("") do |string, element|
            if !element[:left].nil?
              string + element[:left]
            else
              string + element[:right]
            end
          end
        else
          value
        end
      {
        # remove whitespace after cast
        key.to_sym => String(merged_string).strip
      }
    end
    rule(:snake_case_key => simple(:key), :file_path => simple(:value)) do
      {
        key.to_sym => Pathname.new(value)
      }
    end
    # depends on wannabe_bool refining String class
    rule(:snake_case_key => simple(:key), :boolean => simple(:value)) do
      {
        key.to_sym => String(value).to_b
      }
    end
    rule(:snake_case_key => simple(:key), :array => simple(:value)) do
      {
        key.to_sym => String(value).split(",")
      }
    end

    rule(:snake_case_key => simple(:key), :ip_address => subtree(:value)) do
      {
        key.to_sym => IPAddr.new((value.values.first.to_s))
      }
    end

    # ini files are trees of a fixed height, if the file handle is the root
    # subgroups are its children, and subgroup members are the next level of children
    rule(:group => subtree(:group_members)) do
      group_title = group_members[0][:group_title].to_sym
      group_values = Subgroup.new(group_members[1..-1].reduce({}, :merge!))
      {
        group_title => group_values
      }
    end

    # where does overrides come from? an argument into #apply on
    # Transformer, that allows an additional capture outside the AST
    # to be added to the context of the transform
    rule(
      :key_to_be_overridden => subtree(:overridden_key),
      :optional_key => subtree(:overriding_key),
      :file_path => subtree(:new_file_path),
    ) do
      if override.to_sym == overriding_key[:snake_case_key].to_sym
        {
          overridden_key[:snake_case_key] => Pathname.new(new_file_path)
        }
      else
        {
        }
      end
    end
  end
end
