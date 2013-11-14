#!/usr/bin/env ruby
# vim: ts=2 sw=2:
# bel2rdf: Parse BEL, Emit RDF
# 
# usage: ruby bel2rdf.rb FILE.bel
# usage: echo -e "p(HGNC:AKT1) => p(HGNC:AKT2)" | ruby bel2rdf.rb
class Observe
  def update(obj)
    puts obj
  end
end

if __FILE__ == $0
  if ARGV[0]
    content = (File.exists? ARGV[0]) ? File.open(ARGV[0]).read : ARGV[0]
  else
    content = $stdin.read
  end

  require 'bel'
  include BEL::Script
  parser = Parser.new
  parser.add_observer Observe.new
  parser.parse(content)
end
