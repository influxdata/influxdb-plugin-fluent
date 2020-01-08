# The MIT License
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
#
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'influxdb/plugin/fluent/version'

Gem::Specification.new do |spec|
  spec.name          = 'influxdb-plugin-fluent'
  spec.version       = if ENV['CIRCLE_BUILD_NUM']
                         "#{InfluxDB::Plugin::Fluent::VERSION}-#{ENV['CIRCLE_BUILD_NUM']}"
                       else
                         InfluxDB::Plugin::Fluent::VERSION
                       end
  spec.authors       = ['Jakub Bednar']
  spec.email         = ['jakub.bednar@gmail.com']

  spec.summary       = 'InfluxDB 2 output plugin for Fluentd'
  spec.description   = 'A buffered output plugin for Fluentd and InfluxDB 2'
  spec.homepage      = 'https://github.com/bonitoo-io/influxdb-plugin-fluent'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/bonitoo-io/influxdb-plugin-fluent'
  spec.metadata['changelog_uri'] = 'https://raw.githubusercontent.com/bonitoo-io/influxdb-plugin-fluent/master/CHANGELOG.md'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|smoke)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2.0'

  spec.add_runtime_dependency 'fluentd', '~> 1.8'
  spec.add_runtime_dependency 'influxdb-client', '~> 1.0.0.pre.116'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'codecov', '~> 0.1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.66.0'
  spec.add_development_dependency 'simplecov', '~> 0.17.1'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'webmock', '~> 3.7'
end
