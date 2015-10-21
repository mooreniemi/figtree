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
			let(:string_tree) do
        Parser.new.parse_with_debug("[database]\nserver = is here\n")
				Parser.new.parse("[database]\nserver = is here\n")
			end
			let(:ip_tree) do
				Parser.new.parse("[database]\nserver = 192.0.2.62")
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
			it 'it can apply a string type conversion' do
				expect(Transformer.new.apply(string_tree)).to eq(
					[
						{
							database: Subgroup.new(server: "is here")
						}
					]
				)
			end
			it 'it can apply an ip address type conversion' do
				expect(Transformer.new.apply(ip_tree)).to eq(
					[
						{
							database: Subgroup.new(server: IPAddr.new("192.0.2.62"))
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
				expect(Transformer.new.apply(override_tree, override: :production)).to eq(
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
