require 'spec_helper'

module Figtree
  describe Transformer do
    context "can do type conversion" do
      let(:int_tree) do
        Parser.new.parse("[common]\nbasic_size_limit = 26214400\n")
      end
      let(:arr_tree) do
        Parser.new.parse("[http]\nparams = array,of,values\n")
      end
      let(:bool_tree) do
        Parser.new.parse("[ftp]\nenabled = no\n")
      end
      it 'can apply an int type conversion' do
        expect(Transformer.new.apply(int_tree)).to eq(
          [
            {
              common: Subgroup.new({basic_size_limit: 26214400})
            }
          ]
        )
      end
      it 'can apply an array type conversion' do
        expect(Transformer.new.apply(arr_tree)).to eq(
          [
            {
              http: Subgroup.new(params: ["array", "of", "values"])
            }
          ]
        )
      end
      it 'can apply a bool type conversion' do
        expect(Transformer.new.apply(bool_tree)).to eq(
          [
            {
              ftp: Subgroup.new(enabled: false)
            }
          ]
        )
      end
    end
    context "overrides by angle brackets" do
      let(:override_tree) do
        Parser.new.parse("[http]\npath = /srv/\npath<production> = /srv/var/tmp/\n")
      end
      it 'can apply an override' do
        expect(Transformer.new.apply(override_tree, overrides: [:production])).to eq(
          [
            {
              http: Subgroup.new(path: '/srv/var/tmp/')
            }
          ]
        )
      end
    end
  end
end
