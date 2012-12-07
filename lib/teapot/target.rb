# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'pathname'
require 'teapot/build'
require 'teapot/dependency'

module Teapot
	class BuildError < StandardError
	end
	
	class Target
		include Dependency
		
		def initialize(context, package, name)
			@context = context
			@package = package

			@name = name

			@install = nil

			@path = @package.path
		end

		attr :context
		attr :package
		attr :name

		attr :path

		def builder
			Build.top(@path)
		end

		def install(&block)
			@install = Proc.new(&block)
		end

		def install!(context, config = {})
			return unless @install
			
			chain = Dependency::chain(context.selection, dependencies, context.targets.values)
			
			environments = []
			
			# The base configuration environment:
			environments << context.config.environment
			
			# The dependencies environments':
			environments += chain.provisions.collect do |provision|
				Environment.new(&provision.value)
			end
			
			# Per-configuration package package environment:
			environments << @package.options[:environment]
			
			# Merge all the environments together:
			environment = Environment.combine(*environments)
				
			local_build = environment.merge do
				default platforms_path context.config.platforms_path
				default build_prefix {platforms_path + "cache/#{platform_name}-#{variant}"}
				default install_prefix {platforms_path + "#{platform_name}-#{variant}"}
			
				append buildflags {"-I#{install_prefix + "include"}"}
				append linkflags {"-L#{install_prefix + "lib"}"}
			end
			
			@install.call(local_build)
		end

		def to_s
			"<Target: #{@name}>"
		end
	end
end