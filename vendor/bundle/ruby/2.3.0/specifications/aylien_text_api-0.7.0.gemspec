# -*- encoding: utf-8 -*-
# stub: aylien_text_api 0.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "aylien_text_api".freeze
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Aylien Inc.".freeze, "Hamed Ramezanian".freeze]
  s.date = "2016-05-21"
  s.description = "AYLIEN Text Analysis API is a package of Natural Language Processing and Machine Learning-powered tools for analyzing and extracting various kinds of information from text and images.".freeze
  s.email = ["support@aylien.com".freeze, "hamed.r.nik@gmail.com".freeze]
  s.homepage = "https://github.com/AYLIEN/aylien_textapi_ruby".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9".freeze)
  s.rubygems_version = "2.7.4".freeze
  s.summary = "AYLIEN Text Analysis API is a package of Natural Language Processing and Machine Learning-powered tools for analyzing and extracting various kinds of information from text and images.".freeze

  s.installed_by_version = "2.7.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.4"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.4"])
      s.add_development_dependency(%q<vcr>.freeze, ["~> 2.9"])
      s.add_development_dependency(%q<webmock>.freeze, ["~> 1.20"])
    else
      s.add_dependency(%q<rake>.freeze, ["~> 10.4"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.4"])
      s.add_dependency(%q<vcr>.freeze, ["~> 2.9"])
      s.add_dependency(%q<webmock>.freeze, ["~> 1.20"])
    end
  else
    s.add_dependency(%q<rake>.freeze, ["~> 10.4"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.4"])
    s.add_dependency(%q<vcr>.freeze, ["~> 2.9"])
    s.add_dependency(%q<webmock>.freeze, ["~> 1.20"])
  end
end
