# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "rabobank_transactions_downloader"
  s.version     = "0.1.0"
  s.authors     = ["Maarten Hoogendoorn"]
  s.email       = ["maarten@moretea.nl"]
  s.description = "Download your transactions from the Rabobank"
  s.summary     = s.description
  s.license     = "BSD"
  s.homepage    = "http://github.com/moretea/rabobank_transactions_downloader"

  s.files = Dir.glob("{lib,doc}/**/*") + %w(README.md LICENSE)
  s.require_paths = ["lib"]

  s.add_runtime_dependency("capybara", ["~> 2.1.0"])
  s.add_runtime_dependency("capybara-webkit", ["~> 1.0.0"])

  s.add_development_dependency("rspec", "~> 2.14")
end
