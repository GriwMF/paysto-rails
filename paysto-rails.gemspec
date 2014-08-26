# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paysto/version'

Gem::Specification.new do |spec|
  spec.name          = 'paysto-rails'
  spec.version       = Paysto::VERSION
  spec.authors       = ['Andrey Baiburin']
  spec.email         = ['fbandrey@gmail.com']
  spec.description   = %q{Paysto.com implementation for Ruby on Rails applications}
  spec.summary       = %q{Paysto.com implementation for Ruby on Rails applications}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'i18n'
end
