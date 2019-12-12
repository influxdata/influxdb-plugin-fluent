lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'influxdb/plugin/fluentd/version'

Gem::Specification.new do |spec|
  spec.name          = 'influxdb-plugin-fluentd'
  spec.version       = if ENV['CIRCLE_BUILD_NUM']
                         "#{InfluxDB::Plugin::Fluentd::VERSION}-#{ENV['CIRCLE_BUILD_NUM']}"
                       else
                         InfluxDB::Plugin::Fluentd::VERSION
                       end
  spec.authors       = ['Jakub Bednar']
  spec.email         = ['jakub.bednar@gmail.com']

  spec.summary       = 'InfluxDB 2 output plugin for Fluentd'
  spec.description   = 'A buffered output plugin for Fluentd and InfluxDB 2'
  spec.homepage      = 'https://github.com/bonitoo-io/influxdb-plugin-fluentd'
  spec.license       = 'MIT'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/bonitoo-io/influxdb-plugin-fluentd'
  spec.metadata['changelog_uri'] = 'https://raw.githubusercontent.com/bonitoo-io/influxdb-plugin-fluentd/master/CHANGELOG.md'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features|smoke)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2.0'

  # spec.add_runtime_dependency 'fluentd', '~> 1.8'
  spec.add_runtime_dependency 'influxdb-client', '~> 1.0.0.pre.58'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'codecov', '~> 0.1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.66.0'
  spec.add_development_dependency 'simplecov', '~> 0.17.1'
end
