require 'parslet'

class Figtree < Parslet::Parser
  rule(:group_title) { match('[a-zA-Z]').repeat(1) }
  rule(:newline) { match('\\n')  }
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
  rule(:snake_case_key) {
    match('[a-zA-Z0-9_]').repeat(1)
  }
  #TODO should i use http://www.rubydoc.info/github/kschiess/parslet/Parslet.infix_expression here?
  rule(:assignment) {
    snake_case_key >>
    space >>
    str("=") >>
    space >>
    snake_case_key
  }
  #rule(:line) { grouper >> comment }
  #rule(:lines) { line.repeat }
  #root(:lines)
end

def load_config(file_path, overrides=[])
  # parse the contents
  parse(File.read(file_path))
  # convert parsed content to OStruct
end

def parse(str)
  mini = Figtree.new
  mini.parse(str)
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end
