
Gem::Specification.new do |s|

  s.name = 'botaku'

  s.version = File.read(
    File.expand_path('../lib/botaku.rb', __FILE__)
  ).match(/ VERSION *= *['"]([^'"]+)/)[1]

  s.platform = Gem::Platform::RUBY
  s.authors = [ 'John Mettraux' ]
  s.email = [ 'jmettraux@gmail.com' ]
  s.homepage = 'https://github.com/jmettraux/botaku'
  s.license = 'MIT'
  s.summary = 'a Slack bot abstraction'

  s.description = %{
A Slack bot abstraction, built on top of faye-websocket and httpclient.
  }.strip

  #s.files = `git ls-files`.split("\n")
  s.files = Dir[
    'README.{md,txt}',
    'CHANGELOG.{md,txt}', 'CREDITS.{md,txt}', 'LICENSE.{md,txt}',
    'Makefile',
    'lib/**/*.rb', #'spec/**/*.rb', 'test/**/*.rb',
    "#{s.name}.gemspec",
  ]

  s.add_runtime_dependency 'faye-websocket', '~> 0.10'
  s.add_runtime_dependency 'httpclient', '~> 2.8'

  #s.add_development_dependency 'rspec', '>= 2.13.0'

  s.require_path = 'lib'
end

