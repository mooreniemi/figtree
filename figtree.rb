require 'parslet'

class Figtree < Parslet::Parser
  rule(:identifier) { match('[a-z]').repeat(1) }
  rule(:grouper) {
    str('[') >>
    identifier >>
    str(']')
  }
  root(:grouper)
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

describe "Figtree" do
  let(:settings_path) { 'settings.conf' }
  it 'can parse group names' do
    expect(parse('[common]')).to eq(nil)
  end
  xit 'can parse integers' do
    expect(load_config(settings_path)).to eq(nil)
  end
end
