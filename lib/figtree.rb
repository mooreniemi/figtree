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
    (match('[a-zA-Z]').repeat(1) >> (str(',') >> match('[a-zA-Z]').repeat(1)).repeat.maybe).maybe.as(:array) >>
    (str(',') | newline | eof)
  end

  rule(:file_path) do
    match('[/a-z/]').repeat(1).as(:file_path)
  end

  rule(:snake_case_key) do
    match('[a-zA-Z0-9_]').repeat(1).as(:snake_case_key)
  end

  rule(:snakey_option_key) do
    snake_case_key.as(:snake_case_key) >>
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
  rule(:snake_case_key => simple(:key), :number => subtree(:value)) do
    {key.to_sym => Integer(value)}
  end
  rule(:group => subtree(:group_members)) do
    {
      group_members[0][:group_title].to_sym => OpenStruct.new(group_members[1])
    }
  end
end

class Config < OpenStruct
  def initialize(hash = {})
    super(hash.reduce({}, :merge))
  end
end

def load_config(file_path, overrides=[])
  parsed_output = figgy_parse(File.read(file_path), overrides)
  Config.new(figgy_transform(parsed_output))
end

def figgy_parse(str, overrides=[])
  Figtree.new.parse(str)
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end

def figgy_transform(tree)
  Transformer.new.apply(tree)
end
