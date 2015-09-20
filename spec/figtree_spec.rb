require 'figtree'
require 'parslet/rig/rspec'

describe Figtree do
  let(:parser) { Figtree.new }
  it 'can parse newlines' do
    # note Ruby needs you to use "" to make \n work
    expect(parser.newline).to parse("\n")
  end
  it 'can parse group names' do
    expect(parser.grouper).to parse('[common]')
  end
  it 'can parse comments' do
    expect(parser.comment).to parse('; This is a comment\n')
  end
  it 'can parse snake_case keys' do
    expect(parser.snake_case_key).to parse('basic_size_limit')
  end
  it 'can parse assignments' do
    expect(parser.assignment).to parse('basic_size_limit = 26214400')
    expect(parser.assignment).to_not parse('path<itscript> = /srv/tmp/')
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
    let(:settings_path) { 'settings.conf' }
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
    it 'can parse the whole Kebab' do
      expect(load_config(settings_path)).to eq(nil)
    end
  end
end
