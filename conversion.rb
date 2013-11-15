# vim: ts=2 sw=2:
# Converts BEL::Script::Statement objects to RDF triples.

require 'rdf'
require 'rdf/turtle'
require './vocabulary.rb'

module BELRDF

  class Serializer
    attr_reader :writer

    def initialize(stream)
      @writer = RDF::Turtle::Writer.new($stdout, {
          :stream   => stream,
          :base_uri => "http://www.selventa.com/bel/",
          :prefixes => {
             :bel    => "http://www.selventa.com/bel/",
             :belv   => "http://www.selventa.com/vocabulary/",
             :rdf    => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
             :rdfs   => "http://www.w3.org/2000/01/rdf-schema#",
             :HGNC   => "http://www.selventa.com/entity/hgnc-approved-symbols",
             :MESHCL => "http://www.selventa.com/bel/entity/mesh-cellular-locations",
             :SFAM   => "http://www.selventa.com/entity/selventa-protein-families/",
             :CHEBI  => "http://www.selventa.com/entity/chebi-names/"
          }
        }
      )
    end

    def <<(trpl)
      @writer.write_statement(RDF::Statement(*trpl))
    end

    def done
      @writer.write_epilogue
    end
  end
end
