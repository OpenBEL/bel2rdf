#!/usr/bin/env ruby
# vim: ts=2 sw=2:
# rdf_orthology: Convert orthology BEL to RDF.
#
# From BEL file
# usage: ruby rdf_orthology.rb FILE.bel
# From standard in
# usage: echo "<BEL DOCUMENT STRING>" | ruby rdf_orthology.rb

require 'bel'
require './conversion.rb'

class Main

  HGNC = RDF::Vocabulary.new("http://www.selventa.com/bel/namespace/hgnc-approved-symbols/")
  MGI  = RDF::Vocabulary.new("http://www.selventa.com/bel/namespace/mgi-approved-symbols/")
  RGD  = RDF::Vocabulary.new("http://www.selventa.com/bel/namespace/rgd-approved-symbols/")
  BELV = RDF::Vocabulary.new("http://www.selventa.com/vocabulary/")

  def initialize(content, ttl)
    @ttl = ttl
    parser = BEL::Script::Parser.new
    parser.add_observer self
    parser.parse(content)
  end
  def update(obj)
    if obj.is_a? BEL::Script::Statement
      return if not obj.rel == :orthologous

      from_param = obj.subject.args[0]
      to_param = obj.object.args[0]

      from_vocab = Main::const_get from_param.ns
      to_vocab = Main::const_get to_param.ns
      @ttl << RDF::Statement(from_vocab[from_param.value], BELV.orthologousMatch, to_vocab[to_param.value])
      @ttl << RDF::Statement(to_vocab[to_param.value], BELV.orthologousMatch, from_vocab[from_param.value])
      return
    end
  end

  private

  def error_file(file_name)
    $stderr.puts "#{file_name} is not readable"
    exit 1
  end
end

if __FILE__ == $0
  if ARGV[0]
    content = (File.exists? ARGV[0]) ? File.open(ARGV[0]).read : ARGV[0]
  else
    content = $stdin.read
  end
  ttl = BELRDF::Serializer.new(true)
  prog = Main.new(content, ttl)
  ttl.done
end
