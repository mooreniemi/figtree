require 'spec_helper'

module Figtree
  describe Transformer do
    let(:tree) do
      Parser.new.parse("[common]\nbasic_size_limit = 26214400\n")
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
end
