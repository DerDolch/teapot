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

require 'teapot/commands'

module Teapot
	module Build
		module Linker
			class UnsupportedPlatform < StandardError
			end

			def self.link_static(environment, library_file, objects)
				if RUBY_PLATFORM =~ /darwin/
					Commands.run(
						environment[:libtool] || "libtool",
						"-static", "-o", library_file, objects,
					)
				elsif RUBY_PLATFORM =~ /linux/
					FileUtils.rm_rf library_file

					Commands.run(
						environment[:ar] || 'ar',
						environment[:arflags] || "-cru",
						library_file, objects
					)
				else
					raise UnsupportedPlatform.new("Cannot determine linker for #{RUBY_PLATFORM}!")
				end
			end
		end
	end
end