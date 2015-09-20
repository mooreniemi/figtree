require 'parslet'

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
    (str('no') | str('yes'))
  end

  rule(:number) do
    match('[0-9]').repeat(1)
  end

  rule(:array) do
    (snake_case_key >> (str(',') >> snake_case_key).repeat.maybe).maybe.as(:array) >>
    (str(',') | newline | eof)
  end

  rule(:file_path) do
    str('/') >>
    (snake_case_key >> (str('/') >> snake_case_key).repeat.maybe).maybe.as(:file_path) >>
    str('/').maybe
  end

  rule(:snake_case_key) do
    match('[a-zA-Z0-9_]').repeat(1)
  end

  rule(:snakey_option_key) do
    snake_case_key >> str('<') >> snake_case_key >> str('>')
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

def load_config(file_path, overrides=[])
  # parse the contents
  figgy_parse(File.read(file_path))
  # convert parsed content to OStruct
end

def figgy_parse(str)
  figgy = Figtree.new
  figgy.parse(str)
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end
