Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_unicredit_pagonline'
  s.version     = '1.3.2'
  s.summary     = 'Spree commerce extension for Unicredit PagOnline'
  s.description = 'Spree commerce extension for Unicredit PagOnline'
  s.required_ruby_version = '>= 1.9.2'

  s.author            = 'Matteo Folin'
  s.email             = 'mfolin@f5lab.com'
  s.homepage          = 'http://f5lab.com'
  # s.rubyforge_project = 'actionmailer'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 1.3.2')
  s.add_dependency('httparty', '~> 0.13.1')
end
