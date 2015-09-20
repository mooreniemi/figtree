require 'parslet'

class Mini < Parslet::Parser
  rule(:integer) { match('[0-9]').repeat(1) }
  root(:integer)
end

def load_config(file_path, overrides=[])
  # parse the contents
  parse(File.read(file_path))
  # convert parsed content to OStruct
end

def parse(str)
  mini = Mini.new

  mini.parse(str)
rescue Parslet::ParseFailed => failure
  puts failure.cause.ascii_tree
end

describe "Figtree" do
  let(:settings_path) { 'settings.conf' }
  it 'can parse integers' do
    expect(load_config(settings_path)).to eq(nil)
  end
end
