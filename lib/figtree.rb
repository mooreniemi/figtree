require 'parslet'
require 'ostruct'

# ConFIG into a Tree :)
class Figtree < Parslet::Parser
  rule(:eof) { any.absent? }
  rule(:group_title) { match('[a-zA-Z]').repeat(1) }
  rule(:newline)  { match("\\n").repeat(1) >> match("\\r").maybe }
  rule(:space) { match('\s').repeat(0) }
  rule(:grouper) do
    str('[') >>
    group_title.as(:group_title) >>
    str(']')
  end

  rule(:comment) do
    str(';') >>
    (newline.absent? >> any).repeat
  end

  rule(:string) do
    str('"') >>
    ((str('\\') >> any) | (str('"').absent? >> any)).repeat.as(:string) >>
    str('"')
  end

  rule(:boolean) do
    (str('no') | str('yes')).as(:boolean)
  end

  rule(:number) do
    match('[0-9]').repeat(1).as(:number)
  end

  rule(:array) do
    (match('[a-zA-Z]').repeat(1) >>
     (str(',') >>
      match('[a-zA-Z]').repeat(1)).repeat.maybe).maybe.as(:array) >>
    (str(',') | newline | eof)
  end

  rule(:file_path) do
    match('[/a-z/]').repeat(1).as(:file_path)
  end

  rule(:snake_case_key) do
    match('[a-zA-Z0-9_]').repeat(1).as(:snake_case_key)
  end

  rule(:snakey_option_key) do
    snake_case_key.as(:key_to_be_overridden) >>
    str('<') >>
    snake_case_key.as(:optional_key) >>
    str('>')
  end

  rule(:assignment) do
    snake_case_key >>
    space >>
    str("=") >>
    space >>
    (number | boolean | array | snake_case_key | file_path | string)
  end

  rule(:override_assignment) do
    snakey_option_key >>
    space >>
    str("=") >>
    space >>
    file_path
  end

  rule(:assignment_or_comment) do
    ( comment | assignment | override_assignment )
  end

  rule(:group_member) do
    newline.maybe >>
    assignment_or_comment >>
    newline.maybe
  end

  rule(:group) do
    (grouper >>
     group_member.repeat.maybe).as(:group).
    repeat.maybe
  end

  root(:group)
end

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
      key.to_sym => Array(value)
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

class Config < OpenStruct
  def initialize(array = [])
    # TODO move the reduction to #load_config
    # TODO then this class can be a shell
    super(array.reduce({}, :merge))
  end
end

# TODO this feels like a class level method to an undefined class
def load_config(file_path, overrides=[])
  Config.new(
    figgy_transform(
      figgy_parse(
        File.read(file_path)
      ),
      overrides
    )
  )
end

# TODO these would be private methods to help the above class method
def figgy_parse(str)
  Figtree.new.parse(str)
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end

def figgy_transform(tree, overrides = [])
  Transformer.new(overrides).apply(tree)
rescue
  puts 'failed transform'
  {} # returning hash just to preserve stack trace
end
