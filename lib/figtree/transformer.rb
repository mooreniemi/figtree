require 'parslet'
require 'ostruct'

module Figtree
  # once you have an AST, you can do type transformations
  class Transformer < Parslet::Transform
    attr_accessor :overrides

    def initialize(overrides = [], &block)
      @overrides = overrides
      super(&block)
    end

    # TODO these could largely be consolidated with some rearrangement
    # TODO subtree is considered too flexible, switch to simple(:x)?
    rule(:snake_case_key => simple(:key), :number => subtree(:value)) do
      {
        key.to_sym => Integer(value)
      }
    end
    rule(:snake_case_key => simple(:key), :array => subtree(:value)) do
      {
        key.to_sym => String(value).split(",")
      }
    end
    rule(:snake_case_key => simple(:key), :string => subtree(:value)) do
      {
        key.to_sym => String(value)
      }
    end
    rule(:snake_case_key => simple(:key), :boolean => simple(:value)) do
      {
        # Boolean(value) fails
        key.to_sym => String(value)
      }
    end
    rule(:snake_case_key => simple(:key), :file_path => subtree(:value)) do
      {
        key.to_sym => String(value)
      }
    end
    rule(
      :key_to_be_overridden => subtree(:a),
      :optional_key => subtree(:b),
      :file_path => subtree(:c)
    ) do
      if !@overrides.nil? && @overrides.include?(b[:snake_case_key])
        {
          a[:snake_case_key] => String(c)
        }
      else
        {
        }
      end
    end
    rule(:group => subtree(:group_members)) do
      group_title = group_members[0][:group_title].to_sym
      group_values = OpenStruct.new(group_members[1..-1].reduce({}, :merge))
      {
        group_title => group_values
      }
    end
  end
end
