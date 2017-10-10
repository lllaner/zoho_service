# -*- encoding: utf-8 -*-
# stub: zoho_service 0.0.1 ruby lib
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zoho_service/version'

Gem::Specification.new do |s|
  s.name = "zoho_service".freeze
  s.version = ZohoService::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["chaky222".freeze]
  s.date = "2017-09-13"
  s.description = "Working with data in Zoho Service Desk by using API.".freeze
  s.email = ["chaky22222222@gmail.com".freeze]
  s.executables = ["zoho_service".freeze]
  s.files = [".coveralls.yml".freeze, ".gitignore".freeze, ".rspec".freeze, "Gemfile".freeze, "LICENSE.txt".freeze, "README.md".freeze, "Rakefile".freeze, "bin/zoho_service".freeze, "lib/zoho_service.rb".freeze, "lib/zoho_service/base.rb".freeze, "lib/zoho_service/api_connector.rb".freeze, "lib/zoho_service/api_collection.rb".freeze, "lib/zoho_service/version.rb".freeze, "spec/spec_helper.rb".freeze, "spec/zoho_service_spec.rb".freeze, "zoho_service.gemspec".freeze]
  s.homepage = "".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2".freeze
  s.summary = "Zoho Service Desk gem".freeze
  s.test_files = ["spec/spec_helper.rb".freeze, "spec/zoho_service_spec.rb".freeze]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>.freeze, ["0.13.7"])
      s.add_runtime_dependency(%q<activesupport>.freeze, ["~> 4.2.7.1"])
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.5"])
      s.add_development_dependency(%q<rake>.freeze, ["< 11.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 2.14.1"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7.1"])
      s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.7.0"])
    else
      s.add_dependency(%q<httparty>.freeze, ["0.13.7"])
      s.add_dependency(%q<activesupport>.freeze, ["~> 4.2.7.1"])
      s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
      s.add_dependency(%q<rake>.freeze, ["< 11.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 2.14.1"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7.1"])
      s.add_dependency(%q<coveralls>.freeze, ["~> 0.7.0"])
    end
  else
    s.add_dependency(%q<httparty>.freeze, ["0.13.7"])
    s.add_dependency(%q<activesupport>.freeze, ["~> 4.2.7.1"])
    s.add_dependency(%q<bundler>.freeze, ["~> 1.5"])
    s.add_dependency(%q<rake>.freeze, ["< 11.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 2.14.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7.1"])
    s.add_dependency(%q<coveralls>.freeze, ["~> 0.7.0"])
  end
end
