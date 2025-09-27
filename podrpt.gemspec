require_relative "lib/podrpt/version"

Gem::Specification.new do |spec|
  spec.name          = "podrpt"
  spec.version       = Podrpt::VERSION
  spec.authors       = ["Andrew Alves"]
  spec.email         = ["drew_swiftab@proton.me"]
  spec.homepage      = "https://github.com/swiftdrew/podrpt"
  spec.summary       = "Analisa e relata dependências CocoaPods desatualizadas."
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "bin"
  spec.executables   = ["podrpt"]
  spec.require_paths = ["lib"]

  spec.add_dependency "cocoapods", "~> 1.11"
  spec.add_dependency "concurrent-ruby", "~> 1.2"
  spec.add_dependency "httparty", "~> 0.21"
  spec.add_dependency "yaml"
end