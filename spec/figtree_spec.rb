require 'spec_helper'
# for the performance test at bottom
require 'benchmark'

describe Figtree do
  describe '#load_config' do
    let(:settings_path) { 'spec/support/settings.conf' }
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
        :path => "/srv/var/tmp/",
      )
    end

    let(:the_whole_kebab) do
      Figtree::IniConfig.new(
        [
          {
            common: OpenStruct.new(
              {
                :basic_size_limit => 26214400,
                :student_size_limit=> 52428800,
                :paid_users_size_limit=> 2147483648,
                :path=> "/srv/var/tmp/"
              }
            )
          },
          {
            ftp: OpenStruct.new(
              {
                :name => "hello there, ftp uploading",
                :path => "/tmp/",
                :enabled => "no"
              }
            )
          },
          {
            http: OpenStruct.new(
              {
                :name => "http uploading",
                :path => "/tmp/",
                :params => ["array,of,values"]
              }
            )
          }
        ]
      )
    end

    it 'can parse a group and provide dot notation access' do
      expect(Figtree.load_config(settings_path).common).to eq(common)
    end
    it 'can parse the overrides correctly' do
      expect(Figtree.load_config(settings_path, [:itscript]).common).
        to eq(common_with_override)
    end
    it 'can parse the whole Kebab without any misunderstandings' do
      expect(Figtree.load_config(settings_path)).to eq(the_whole_kebab)
    end

    it 'can parse the whole ini file quickly' do
      Benchmark.realtime do
        Figtree.load_config(settings_path)
      end.should be < 0.02
    end
  end
end
