require 'spec_helper'

module Figtree
  describe Parser do
    let(:parser) { Parser.new }
    it 'can parse newlines' do
      expect(parser.newline).to parse("\n")
    end
    it 'can parse group names' do
      expect(parser.grouper).to parse('[common]')
    end
    it 'can parse comments' do
      expect(parser.comment).to parse("; This is a comment\n")
      expect(parser.comment).to parse("; last modified 1 April 2001 by John Doe\n")
      comment_first = File.open('spec/support/wiki_example.ini', &:readline)
      expect(parser.comment).to parse(comment_first)
    end
    it 'can parse comments then groups' do
      expect(parser.comment_or_group).to parse("; comment\n[groop]\nassignment = present")
    end
    it 'can parse snake_case keys' do
      expect(parser.snake_case_key).to parse('basic_size_limit')
    end
    it 'can parse strings' do
      expect(parser.string).to parse('"hello there, ftp uploading"')
    end
    it 'can parse arrays' do
      expect(parser.array).to parse("a,")
      expect(parser.array).to parse("a,b")
      expect(parser.array).to parse("a,b,c\n")
      expect(parser.array).to_not parse(',,')
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
    end
    it 'can parse keys with optional overrides' do
      expect(parser.snakey_option_key).to parse('path<itscript>')
    end
    it 'can parse file_paths' do
      expect(parser.file_path).to parse('/srv/tmp/')
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
          "pepes = 0"
        ].join("\n") + "\n"
      }

      it 'parses a group member' do
        expect(parser.group_member).to parse("\nbasic_size_limit = 26214400\n")
      end
      it 'can parse single assignment inside a group' do
        expect(parser.group).
          to parse("[common]\nbasic_size_limit = 26214400\n")
      end
      it 'can parse multiple assignments inside a group' do
        expect(parser.group).
          to parse("[common]\nbasic_size_limit = 26214400\nstudent_size_limit = 52428800\n")
      end
      it 'can parse multiple groups' do
        expect(parser.group).to parse(multi_group)
      end

    end
  end
end
