require 'parslet'
require 'figtree/ip_rules'

module Figtree
  # ConFIG into a Tree :)
  class Parser < Parslet::Parser
    include IPv4
    include IPv6

    rule(:eof) { any.absent? }
    rule(:group_title) { match('[a-zA-Z_]').repeat(1) }
    rule(:space) { (match("\s") | str(' ')) }
    rule(:newline) { str("\n") >> match("\r").maybe }
    rule(:terminator) do
      space.repeat(0) >> (comment | newline | eof)
    end
    rule(:backslash) do
      space.repeat(0) >> str("\\")
    end

    rule(:grouper) do
      str('[') >>
      group_title.as(:group_title) >>
      str(']')
    end

    rule(:comment_start) { (str(';') | str('#')) }
    rule(:comment_end) { (newline | eof) }
    rule(:comment) do
      (
        comment_start >>
        space.repeat(0) >>
        (
          comment_end.absent? >> any
        ).repeat
      ) >>
      space.repeat(0) >>
      comment_end
    end

    rule(:quoted_string) do
      str('"') >>
      (
        (str('\\') >> any) | (str('"').absent? >> any)
      ).repeat(1) >>
      str('"')
    end


    rule(:unquoted_string) do
      (
        (
          (
            (backslash | terminator).absent?
          ) >> any
        ).repeat(1).as(:left) >>
        backslash >>
        terminator
      ).repeat(0) >>
      (
        terminator.absent? >> any
      ).repeat(1).as(:right) >>
      terminator
    end

    rule(:string) do
      (quoted_string | unquoted_string).as(:string)
    end

    rule(:boolean) do
      (
        str('no') |
        str('yes') |
        str('false') |
        str('true')
      ).as(:boolean)
    end

    rule(:number) do
      match('[0-9]').repeat(1).as(:number)
    end

    rule(:ip_address) do
      (ipv4 | ipv6).as(:ip_address)
    end

    rule(:at_least_one_char) do
      match('[a-zA-Z]').repeat(1)
    end

    rule(:array) do
      (
        # minimum array
        at_least_one_char >>
        (
          # extending elementwise
          str(',') >> space.repeat.maybe >>
          at_least_one_char
        ).repeat(1)
      ).as(:array) >>
      (newline | eof)
    end

    rule(:file_path) do
      (
        (
          str('/') >>
          at_least_one_char
        ).repeat(1) >>
        str('/').maybe
      ).as(:file_path)
    end

    rule(:snake_case_key) do
      match('[a-zA-Z0-9_]').repeat(1).
        as(:snake_case_key)
    end

    rule(:snakey_option_key) do
      snake_case_key.as(:key_to_be_overridden) >>
      str('<') >>
      snake_case_key.as(:optional_key) >>
      str('>')
    end

    rule(:value) do
      # this ordering matters
      # we are roughly moving from more
      # to less specific
      (
        ip_address |
        number |
        boolean |
        array |
        file_path |
        string
      )
    end

    rule(:equals_value) do
      space.repeat(0) >>
      str("=") >>
      space.repeat(0) >>
      value >>
      newline.repeat(0)
    end

    rule(:assignment) do
      snake_case_key >>
      equals_value
    end

    rule(:override_assignment) do
      snakey_option_key >>
      equals_value
    end

    rule(:assignment_or_comment) do
      ( comment | assignment | override_assignment )
    end

    rule(:group_member) do
      assignment_or_comment >>
      space.repeat(0) >>
      newline.repeat(0)
    end

    rule(:group) do
      (
        grouper >>
        space.repeat(0) >>
        comment.maybe >>
        newline.repeat(0) >>
        group_member.repeat(0)
      ).as(:group).
      repeat(0)
    end

    rule(:comment_or_group) do
      # may start file with attribution
      # comment or timestamp etc
      comment.repeat.maybe >>
      group
    end

    root(:comment_or_group)
  end
end
