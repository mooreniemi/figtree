require 'figtree'
require 'parslet/rig/rspec'

describe Figtree do
  let(:parser) { Figtree.new }
  it 'can parse newlines' do
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

  end
end

describe Transformer do
  let(:tree) do
    Figtree.new.parse("[common]\nbasic_size_limit = 26214400\n")
  end
  it 'can apply an int type conversion' do
    expect(Transformer.new.apply(tree)).to eq(
      [
        {
          common: OpenStruct.new({basic_size_limit: 26214400})
        }
      ]
    )
  end
end

describe '#load_config' do
  let(:settings_path) { 'settings.conf' }
  let(:common) do
    OpenStruct.new(
      :basic_size_limit => 26214400,
      :student_size_limit => 52428800,
      :paid_users_size_limit => 2147483648,
      :path => "/srv/var/tmp/",
    )
  end

  let(:common_with_override) do
    OpenStruct.new(
      :basic_size_limit => 26214400,
      :student_size_limit => 52428800,
      :paid_users_size_limit => 2147483648,
      :path => "/srv/tmp/",
    )
  end

  it 'can parse a group and provide dot notation access' do
    puts load_config(settings_path)
    expect(load_config(settings_path).common).to eq(common)
  end
  it 'can parse the overrides correctly' do
    pending('where is best place to override')
    expect(load_config(settings_path, [:production]).common).to eq(common_with_override) 
  end
  it 'can parse the whole Kebab without any misunderstandings' do
    pending('mostly using this to observe stdout')
    expect(load_config(settings_path)).to eq(nil)
  end
end
