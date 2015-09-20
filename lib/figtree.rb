require 'parslet'

class Figtree < Parslet::Parser
  rule(:group_title) { match('[a-zA-Z]').repeat(1) }
  rule(:newline)  { match("\\n").repeat(1) >> match("\\r").maybe }
  rule(:space) { match('\s').repeat(0) }
  rule(:grouper) {
    str('[') >>
    group_title >>
    str(']')
  }
  rule(:comment) {
    str(';') >>
    (newline.absent? >> any).repeat
  }
  rule(:file_path) {
    str('/') >>
    (snake_case_key >> (str('/') >> snake_case_key).repeat.maybe).maybe.as(:file_path) >>
    str('/')
  }
  rule(:snake_case_key) {
    match('[a-zA-Z0-9_]').repeat(1)
  }
  rule(:snakey_option_key) {
    snake_case_key >> str('<') >> snake_case_key >> str('>')
  }
  #TODO should i use http://www.rubydoc.info/github/kschiess/parslet/Parslet.infix_expression here?
  rule(:assignment) {
    snake_case_key >>
    space >>
    str("=") >>
    space >>
    snake_case_key
  }
  rule(:override_assignment) {
    snakey_option_key >>
    space >>
    str("=") >>
    space >>
    file_path
  }

  rule(:assignment_or_comment) do
    ( comment | assignment | override_assignment )
  end

  rule(:group_member) {
    newline.maybe >>
    assignment_or_comment >>
    newline.maybe
  }

  rule(:group) do
    (grouper >>
     group_member.repeat.maybe).repeat.maybe.as(:group)
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
