require 'spec_helper'

module Figtree
  describe Parser do
    let(:parser) { Parser.new }
    let(:string) do
      "a bb ccc dddd eeeee ffffff\n"
    end

    it 'can parse newlines' do
      expect(parser.newline).to parse("\n")
      expect(parser.newline).to_not parse("\\n")
      expect(parser.newline).to_not parse("\\\n")
    end
    it 'terminates correctly' do
      expect(parser.terminator).to parse("     #comment")
      expect(parser.terminator).to parse("     #comment\n")
      expect(parser.terminator).to parse("   \n")
      expect(parser.terminator).to parse("   ")
      expect(parser.unquoted_string).to parse("f    #ffoo")
      expect(parser.unquoted_string).to parse("f    #ffoo\n")
    end
    it 'can parse group names' do
      expect(parser.grouper).to parse('[common]')
      expect(parser.grouper).to parse('[common_also]')
    end
    it 'can parse comments' do
      expect(parser.comment).to parse("; This is a comment\n")
      expect(parser.comment).to parse("# This is also a comment\n")
      expect(parser.comment).to parse("; last modified 1 April 2001 by John Doe\n")
      expect(parser.comment).to parse("#comment \\n")
      comment_first = File.open('spec/support/wiki_example.ini', &:readline)
      expect(parser.comment).to parse(comment_first)
    end
    it 'can parse comments then groups' do
      expect(parser.comment_or_group).to parse("; comment\n[groop]\nassignment = 0\n")
    end
    it 'can parse snake_case keys' do
      expect(parser.snake_case_key).to parse('basic_size_limit')
    end

    it 'can parse spaces' do
      expect(parser.spaces).to parse("#foo")
      expect(parser.spaces).to parse("# foo")
      expect(parser.spaces).to parse("# foo\n")
      expect(parser.spaces).to_not parse(" ")
      expect(parser.spaces).to_not parse("\s")
      expect(parser.spaces).to_not parse("a b")
    end
    it 'can parse strings' do
      expect(parser.string).to parse('"hello there, ftp uploading"')
    end
    it 'can parse unquoted strings' do
      expect(parser.unquoted_string).to parse(string)
      expect(parser.unquoted_string).to parse("multiline \\\nsupport\n")
    end
    it 'can parse multiline with comment' do
      expect(parser.unquoted_string).to parse("a #comment\n")
      expect(parser.unquoted_string).to parse("a #")
      expect(parser.unquoted_string).to_not parse("a\nb")
      expect(parser.unquoted_string).to parse("a \\#comment\n b\n")
      expect(parser.assignment).to parse("foo = a \\nb\n")
      expect(parser.assignment).to parse("foo = a \\   # and here, too\nb\n")

      group = "[section_three]\nthree   = hello \\\nmultiline\nother = 2"
      expect(parser.group).to parse(group)

      multiline_only = File.read('spec/support/multiline_only.ini')
      expect(parser.group).to parse(multiline_only)
    end

    it 'can parse arrays' do
      expect(parser.array).to_not parse(',,')
      expect(parser.array).to_not parse("a\n")
      expect(parser.array).to_not parse("a,")
      expect(parser.array).to parse("a,b\n")
      expect(parser.array).to parse("a,b")
      expect(parser.array).to parse("a,b,c\n")
      expect(parser.array).to parse("words, with, spaces, after\n")
      expect(parser.array).to parse("several,diff,words,only,nonumbers\n")
      expect(parser.array).to parse("array,of,values\n")
      expect(parser.array).to parse("array,of,values")
    end

    it 'can parse numbers' do
      expect(parser.number).to parse("26214400")
    end

    it 'can parse ip addresses' do
      expect(parser.ip_address).to parse("FE80:0000:0000:0000:0202:B3FF:FE1E:8329")
      expect(parser.ip_address).to parse('111.222.3.4')
      expect(parser.ip_address).to parse('192.0.2.62')
      expect(parser.ip_address).to_not parse('f11.222.3.4')
      expect(parser.ip_address).to_not parse('111.222.3')
    end
    it 'can parse booleans flexibly' do
      expect(parser.boolean).to parse("no")
      expect(parser.boolean).to parse("yes")
    end
    it 'can parse assignments' do
      expect(parser.assignment).to parse('basic_size_limit = 26214400')
      expect(parser.assignment).to parse('path = /srv/var/tmp/')
      expect(parser.assignment).to_not parse('path<itscript> = /srv/tmp/')
      expect(parser.assignment).to parse('name = "hello there, ftp uploading"')
      expect(parser.assignment).to parse('params = array,of,values')
      expect(parser.assignment).to parse("hostname = My Computer\n")
    end
    it 'can parse keys with optional overrides' do
      expect(parser.snakey_option_key).to parse('path<itscript>')
    end
    it 'can parse file_paths' do
      expect(parser.file_path).to parse('/srv/tmp/')
      expect(parser.file_path).to_not parse(string)
    end
    it 'can parse overrides' do
      expect(parser.override_assignment).to parse('path<itscript> = /srv/tmp/')
    end

    describe "using the settings.conf file for input" do
      let(:settings_path) { 'spec/support/settings.conf' }
      let(:multi_group) {
        [
          "[common]",
          "basic_size_limit = 234234",
          "[rare]",
          "pepes = 0",
          "and = feels guy"
        ].join("\n") + "\n"
      }

      it 'parses comment or group' do
        expect(parser.comment_or_group).to parse("[database]\nserver = 192.0.2.62")
      end
      it 'parses a group member' do
        expect(parser.group_member).to parse("basic_size_limit = 26214400\n")
      end
      it 'can parse group members with inline comments' do
        group_with_comments = "[section_two]  # you can comment here" +
          "\none = 42       # and even here!"
        expect(parser.group).to parse(group_with_comments)
      end
      it 'can parse assignment irrespective of spacing' do
        expect(parser.assignment).
          to parse("basic_size_limit=         26214400\n")
        expect(parser.assignment).
          to parse("basic_size_limit          = 26214400\n")
      end
      it 'can parse single assignment inside a group' do
        expect(parser.group).
          to parse("[common]\nbasic_size_limit = 26214400\n")
      end
      it 'can parse multiple assignments inside a group' do
        expect(parser.group).
          to parse("[common]\nbasic_size_limit = 26214400\nstudent_size_limit = 52428800\n")
      end
      it 'can parse values including strings' do
        group_member = "hostname = #{string}"
        expect(parser.group_member).to parse(group_member)
      end
      it 'can parse multiple groups' do
        expect(parser.group).to parse(multi_group)
      end

    end
  end
end
