# frozen_string_literal: true

require_relative 'lib/enum_utils/version'

Gem::Specification.new do |spec|
  spec.name          = 'enum_utils'
  spec.version       = EnumUtils::VERSION
  spec.authors       = ['Max Chernyak']
  spec.email         = ['hello@max.engineer']
  spec.summary       = 'Functions for mixing and matching lazy, potentially ' \
                       'infinite enumerables.'
  spec.homepage      = 'https://github.com/maxim/enum_utils'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.9')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(/\Atest\//) }
  end

  spec.require_paths = ['lib']
end
