$KCODE = 'utf8'
$:.unshift(File.expand_path(File.dirname(__FILE__))) unless $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'uri'
require 'digest/md5'

begin
  require 'activesupport'
rescue LoadError
  require 'rubygems'
  gem 'activesupport', '>=1.4.0'
  require 'activesupport'
end

begin
  require 'utf8proc'
rescue LoadError
  require 'rubygems'
  begin
    gem 'utf8proc', '>=1.0.3'
    require 'utf8proc'
  rescue LoadError
  end
end

begin
  require 'addressable/uri'
rescue LoadError
  require 'rubygems'
  gem 'addressable', '>=2.1.0'
  require 'addressable/uri'
end

begin
  require 'nokogiri'
rescue LoadError
  require 'rubygems'
  gem 'nokogiri', '>=1.3.2'
  require 'nokogiri'
end

module RubyRDF
  # :stopdoc:
  VERSION = '0.99.0'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
                                   ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

  # Generate a new, unique name for a blank node.
  def self.generate_bnode_name
    "bn#{Digest::MD5.hexdigest(rand.to_s + Time.now.to_s)}"
  end

  # Returns true if +node+ is an URI, false otherwise.
  def self.uri?(node)
    node.is_a?(URINode)
  end

  # Returns true if +node+ is a literal (plain or typed), false otherwise.
  def self.literal?(node)
    node.is_a?(PlainLiteral) || node.is_a?(TypedLiteral)
  end

  # Returns true if +node+ is a blank node, false otherwise.
  def self.bnode?(node)
    !uri?(node) && !literal?(node)
  end
end

RubyRDF.require_all_libs_relative_to(__FILE__)
