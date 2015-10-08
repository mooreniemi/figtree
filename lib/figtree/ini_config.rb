require 'ostruct'
module Figtree
  class IniConfig < OpenStruct
    def initialize(array = [])
      # TODO move the reduction to #load_config
      # TODO then this class can be a shell
      super(array.reduce({}, :merge))
    end
  end
end
