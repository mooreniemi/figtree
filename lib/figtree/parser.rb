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
    rule(:spaces) { space.repeat }
    rule(:newline) { match("\n") >> match("\r").maybe }
    rule(:comment_char) { (str(';') | str('#')) }

    rule(:grouper) do
      str('[') >>
      group_title.as(:group_title) >>
      str(']')
    end

    rule(:comment) do
      # comments go uncaptured
      (comment_char >>
       (newline.absent? >> any).repeat) >>
      (eof | newline)
    end

    rule(:quoted_string) do
      str('"') >>
      (
        (str('\\') >> any) | (str('"').absent? >> any)
      ).repeat >>
      str('"')
    end

    rule(:unquoted_string) do
      (newline.absent? >> any).repeat >>
      spaces >>
      str('\\').maybe >>
      spaces >>
      comment.maybe >>
      newline
    end

    rule(:string) do
      (quoted_string | unquoted_string).as(:string)
    end

    rule(:boolean) do
      # TODO expand this check
      (str('no') | str('yes')).as(:boolean)
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
        str(',') >> spaces.maybe >>
        at_least_one_char >>
        (
          # extending elementwise
          str(',') >> spaces.maybe >>
          at_least_one_char
        ).repeat.maybe
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
      ( ip_address |
       number |
       boolean |
       array |
       file_path |
       string )
    end

    rule(:equals_value) do
      space.maybe >>
      str("=") >>
      space.maybe >>
      value
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
      newline.maybe >>
      assignment_or_comment >>
      spaces.maybe >>
      comment.maybe >>
      newline.repeat.maybe
    end

    rule(:group) do
      (
        grouper >>
        spaces.maybe >>
        comment.maybe >>
        group_member.repeat.maybe
      ).as(:group).
      repeat.maybe
    end

    rule(:comment_or_group) do
      # may start file with attribution
      # comment or timestamp etc
      comment.maybe >>
      group
    end

    root(:comment_or_group)
  end
end
