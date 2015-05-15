Gem::Specification.new do |spec|
  spec.name        = 'puppet-lint-fileserver-check'
  spec.version     = '1.2.1'
  spec.homepage    = 'https://github.com/camptocamp/puppet-lint-fileserver-check'
  spec.license     = 'MIT'
  spec.author      = 'Mickaël Canévet'
  spec.email       = 'mickael.canevet@camptocamp.com'
  spec.files       = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.test_files  = Dir['spec/**/*']
  spec.summary     = 'A puppet-lint plugin to check if puppet:/// is used instead of file().'
  spec.description = <<-EOF
    A puppet-lint plugin to check if puppet:/// is used instead of file().
  EOF

  spec.add_dependency             'puppet-lint', '~> 1.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'rake'
end
