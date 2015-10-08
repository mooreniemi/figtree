require 'spec_helper'

module Figtree
  describe Transformer do
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
            common: OpenStruct.new({basic_size_limit: 26214400})
          }
        ]
      )
    end
    it 'can apply an array type conversion' do
      expect(Transformer.new.apply(arr_tree)).to eq(
        [
          {
            http: OpenStruct.new(params: ["array", "of", "values"])
          }
        ]
      )
    end
    it 'can apply a bool type conversion' do
      expect(Transformer.new.apply(bool_tree)).to eq(
        [
          {
            ftp: OpenStruct.new(enabled: false)
          }
        ]
      )
    end
  end
end
