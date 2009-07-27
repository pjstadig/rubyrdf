begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'rubyrdf'

task :default => ['test:run', 'spec:run']

PROJ.name = 'rubyrdf'
PROJ.authors = 'Paul Stadig'
PROJ.email = 'paul@stadig.name'
PROJ.url = 'http://github.com/pjstadig/rubyrdf/'
PROJ.version = RubyRDF::VERSION
PROJ.rubyforge.name = 'rubyrdf'
PROJ.ignore_file = '.gitignore'
PROJ.readme_file = 'README.rdoc'
PROJ.ruby_opts = []
PROJ.test.files = Dir[File.join(File.dirname(__FILE__), %w[test ** *_test.rb])]

PROJ.spec.opts << '--color'

