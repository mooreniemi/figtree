require 'parslet'
require 'ostruct'
require 'wannabe_bool'
require 'pry'

module Figtree
  # once you have an AST, you can do type transformations
  class Transformer < Parslet::Transform
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
        key.to_sym => String(value).to_b
      }
    end
    rule(:snake_case_key => simple(:key), :file_path => subtree(:value)) do
      {
        key.to_sym => String(value)
      }
    end
    rule(
      :key_to_be_overridden => subtree(:overridden_key),
      :optional_key => subtree(:overriding_key),
      :file_path => subtree(:new_file_path),
    ) do
      if overrides.include?(overriding_key[:snake_case_key].to_sym)
        {
          overridden_key[:snake_case_key] => String(new_file_path)
        }
      else
        {
        }
      end
    end
    rule(:group => subtree(:group_members)) do
      group_title = group_members[0][:group_title].to_sym
      group_values = Subgroup.new(group_members[1..-1].reduce({}, :merge!))
      {
        group_title => group_values
      }
    end
  end
end
