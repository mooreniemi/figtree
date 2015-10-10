require 'spec_helper'
# for the performance test at bottom
require 'benchmark'

describe Figtree do
  describe '#load_config' do
    let(:settings_path) { 'spec/support/settings.conf' }
    let(:common) do
      Figtree::Subgroup.new(
        :basic_size_limit => 26214400,
        :student_size_limit => 52428800,
        :paid_users_size_limit => 2147483648,
        :path => "/srv/var/tmp/",
      )
    end

    let(:common_with_override) do
      Figtree::Subgroup.new(
        :basic_size_limit => 26214400,
        :student_size_limit => 52428800,
        :paid_users_size_limit => 2147483648,
        :path => "/srv/tmp/",
      )
    end

    let(:the_whole_kebab) do
      Figtree::IniConfig.new(
        [
          {
            common: Figtree::Subgroup.new(
              {
                :basic_size_limit => 26214400,
                :student_size_limit=> 52428800,
                :paid_users_size_limit=> 2147483648,
                :path=> "/srv/var/tmp/"
              }
            )
          },
          {
            ftp: Figtree::Subgroup.new(
              {
                :name => "hello there, ftp uploading",
                :path => "/tmp/",
                :enabled => false
              }
            )
          },
          {
            http: Figtree::Subgroup.new(
              {
                :name => "http uploading",
                :path => "/tmp/",
                :params => ["array", "of", "values"]
              }
            )
          }
        ].reduce({}, :merge!)
      )
    end

    it 'can parse a group and provide dot notation access' do
      expect(Figtree::IniConfig.new(settings_path).common).to eq(common)
    end
    it 'can parse the overrides correctly' do
      expect(Figtree::IniConfig.new(settings_path, :itscript).common).
        to eq(common_with_override)
    end
    it 'can parse the whole Kebab without any misunderstandings' do
      expect(Figtree::IniConfig.new(settings_path)).to eq(the_whole_kebab)
    end

    it 'can parse the wiki example' do
			wiki_example = Figtree::IniConfig.new('spec/support/wiki_example.ini')
      expect(wiki_example.database.server).to_not be_nil
    end

    context "performance" do
      it 'can parse the whole ini file quickly' do
        expect(
          Benchmark.realtime do
            Figtree::IniConfig.new(settings_path)
          end
        ).to be < 0.025
				# without ip_address parsing this was under 0.014 :(
      end
    end

    context "invalid ini file" do
      let(:unparseable_config) { 'spec/support/unparseable_settings.conf' }
      let(:untransformable_config) { 'spec/support/untransformable_settings.conf' }
      it 'throws ParseFailed if unparseable' do
        expect { Figtree::IniConfig.new(unparseable_config) }.
          to raise_error(Parslet::ParseFailed)
      end
      it 'throws TransformFailed if untransformable' do
        allow_any_instance_of(String).to receive(:to_b).
          and_raise(StandardError)
        expect { Figtree::IniConfig.new(untransformable_config) }.
          to raise_error(Figtree::TransformFailed)
      end
    end
  end
end
