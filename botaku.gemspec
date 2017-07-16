
Gem::Specification.new do |s|

  s.name = 'botaku'

  s.version = File.read(
    File.expand_path('../lib/botaku.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux@gmail.com' ]
  s.homepage = 'http://github.com/jmettraux/botaku'
  #s.rubyforge_project = 'rufus'
  s.license = 'MIT'
  s.summary = 'a Slack bot abstraction'

  s.description = %{
A Slack bot abstraction, built on top of the slack-ruby-client gem.
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'README.{md,txt}',
    'CHANGELOG.{md,txt}', 'CREDITS.{md,txt}', 'LICENSE.{md,txt}',
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    "#{s.name}.gemspec",
  ]

  s.add_runtime_dependency 'slack-ruby-client', '~> 0.8'

  #s.add_development_dependency 'rspec', '>= 2.13.0'

  s.require_path = 'lib'
end

