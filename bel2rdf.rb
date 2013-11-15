#!/usr/bin/env ruby
# vim: ts=2 sw=2:
# bel2rdf: Parse BEL, Emit RDF
# 
# usage: ruby bel2rdf.rb FILE.bel
# usage: echo -e "p(HGNC:AKT1) => p(HGNC:AKT2)" | ruby bel2rdf.rb
if __FILE__ == $0
  if ARGV[0]
    content = (File.exists? ARGV[0]) ? File.open(ARGV[0]).read : ARGV[0]
  else
    content = $stdin.read
  end

  require 'bel'
  require './vocabulary.rb'
  require './conversion.rb'
  class Main
    attr_reader :ttl
    def initialize(content)
      parser = BEL::Script::Parser.new
      parser.add_observer self

      @ttl = BELRDF::Serializer.new
      BELRDF::vocabulary_rdf.each do |trpl|
        @ttl << trpl
      end
      parser.parse(content)
    end
    def update(obj)
      if obj.is_a? BEL::Script::Term
        BELRDF::for_term(obj, @ttl)
      end
    end
  end

  prog = Main.new(content)
  prog.ttl.done
end
