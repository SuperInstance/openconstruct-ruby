# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "openconstruct"
  spec.version       = "0.1.0"
  spec.authors       = ["SuperInstance"]
  spec.summary       = "Ruby client for OpenConstruct — module-driven agent onboarding"
  spec.description   = "Thin Ruby binding for OpenConstruct's phase-flow client, " \
                       "module registry, agent identity, and onboarding config generation."
  spec.homepage      = "https://github.com/SuperInstance/openconstruct-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.files = Dir.glob("lib/**/*.rb") + %w[README.md]
  spec.require_paths = ["lib"]
end
