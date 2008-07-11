desc 'Generate gemspec file'
task :gemspec do
  sh %{ rake debug_gem > rubyrdf.gemspec }
end
