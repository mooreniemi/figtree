require 'figtree'
require 'parslet/rig/rspec'

describe "Figtree" do
  let(:settings_path) { 'settings.conf' }
  let(:parser) { Figtree.new }
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
end
