# vim: ts=2 sw=2:
# Defines the RDF vocabulary for BEL structures.

require 'rdf'

module BELRDF
  BEL  = RDF::Vocabulary.new("http://www.selventa.com/bel/")
  BELV = RDF::Vocabulary.new(BEL.to_s + "vocabulary/")
end
