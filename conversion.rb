# vim: ts=2 sw=2:
# Converts BEL::Script::Statement objects to RDF triples.

require 'rdf'
require 'rdf/turtle'
require './vocabulary.rb'

module BELRDF

  class Serializer
    attr_reader :writer

    def initialize(stream)
      @writer = RDF::NTriples::Writer.new($stdout, {
          :stream   => stream,
          :base_uri => "http://www.openbel.org/bel/",
          :prefixes => {
             :bel    => "http://www.openbel.org/bel/",
             :belv   => "http://www.openbel.org/vocabulary/",
             :rdf    => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
             :rdfs   => "http://www.w3.org/2000/01/rdf-schema#",
             :HGNC   => "http://www.openbel.org/entity/hgnc-approved-symbols",
             :MESHCL => "http://www.openbel.org/bel/entity/mesh-cellular-locations",
             :SFAM   => "http://www.openbel.org/bel/namespace/selventa-protein-families/",
             :CHEBI  => "http://www.openbel.org/bel/namespace/chebi/"
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
