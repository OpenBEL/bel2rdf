#!/usr/bin/env ruby
# vim: ts=2 sw=2:

require 'addressable/uri'
require 'rdf'
require 'rdf/ntriples'

A = RDF::Vocabulary.new('http://www.selventa.com/bel/annotation/')
LINK_IDS = {
  CL_: RDF::Vocabulary.new('http://purl.obolibrary.org/obo/'),
  CLO_: RDF::Vocabulary.new('http://purl.obolibrary.org/obo/'),
  DOID_: RDF::Vocabulary.new('http://purl.obolibrary.org/obo/'),
  EFO_: RDF::Vocabulary.new('http://www.ebi.ac.uk/efo/'),
  UBERON_: RDF::Vocabulary.new('http://purl.obolibrary.org/obo/'),
  D0: RDF::Vocabulary.new('http://bioonto.de/mesh.owl#')
}

def write_annotation_stmts(path, writer, out_file)
  name = /annotations\/([\w-]+).belanno/.match(path)[1]
  out_file << writer.dump([RDF::Statement.new(
    A[name], RDF.type, RDF::SKOS.ConceptScheme)])

  in_values = false
  File.foreach(path) do |l|
    if l.start_with? '[Values]'
      in_values = true
      next
    end
    next if not in_values

    value, link = l.split(%r{\|}).map(&:strip)
    res_uri = RDF::URI(Addressable::URI.encode(A["#{name}/#{value}"].to_s))

    link_vocab = LINK_IDS.find {|k, v| link.start_with? k.to_s}

    out_file << writer.dump([RDF::Statement.new(
      res_uri, RDF.type, RDF::SKOS.Concept)])
    out_file << writer.dump([RDF::Statement.new(
      res_uri, RDF::SKOS.inScheme, A[name])])
    out_file << writer.dump([RDF::Statement.new(
      res_uri, RDF::SKOS.prefLabel, value)])

    if link_vocab
      out_file << writer.dump([RDF::Statement.new(
        res_uri, RDF::RDFS.seeAlso, link_vocab[1][link])])
    end
  end
end

writer = RDF::Writer.for(:ntriples)
File.open("annotations-skos.nt", "w") do |file|
  Dir['annotations/*belanno'].each do |path|
    write_annotation_stmts(path, writer, file)
  end
end
