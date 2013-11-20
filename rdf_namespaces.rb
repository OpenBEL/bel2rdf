#!/usr/bin/env ruby
# vim: ts=2 sw=2:

require 'addressable/uri'
require 'rdf'
require 'rdf/ntriples'

N = RDF::Vocabulary.new('http://www.selventa.com/bel/namespace/')
GO = RDF::Vocabulary.new('http://www.geneontology.org/go#') # need GO:
UNIPROT = RDF::Vocabulary.new('http://purl.uniprot.org/uniprot/') #acc num
CHEBI = RDF::Vocabulary.new('http://purl.obolibrary.org/obo/') # need CHEBI_
DO = RDF::Vocabulary.new('http://purl.obolibrary.org/obo/') # need DOID_

hash = Hash.new {|hash,key| hash[key] = []}
Dir['namespaces/*beleq'].each do |path|
  name = /namespaces\/([\w-]+).beleq/.match(path)[1]
  in_values = false
  File.foreach(path) do |l|
    if l.start_with? '[Values]'
      in_values = true
      next
    end
    next if not in_values
    ident, uuid = l.split(%r{\|}).each { |v| v.strip! }
    hash[uuid] << "#{name}/#{ident}"
  end
end

def write_ns_stmts(hash, path, writer, out_file)
  name = /namespaces\/([\w-]+).beleq/.match(path)[1]
  out_file << writer.dump([RDF::Statement.new(
    N[name], RDF.type, RDF::SKOS.ConceptScheme)])

  in_values = false
  File.foreach(path) do |l|
    if l.start_with? '[Values]'
      in_values = true
      next
    end
    next if not in_values

    ident, uuid = l.split(%r{\|}).each { |v| v.strip! }
    res_uri = RDF::URI(Addressable::URI.encode(N["#{name}/#{ident}"].to_s))

    out_file << writer.dump([RDF::Statement.new(
      res_uri, RDF.type, RDF::SKOS.Concept)])
    out_file << writer.dump([RDF::Statement.new(
      res_uri, RDF::SKOS.inScheme, N[name])])
    out_file << writer.dump([RDF::Statement.new(
      res_uri, RDF::SKOS.prefLabel, ident)])

    if name == 'go-biological-processes-ids' or name == 'go-cellular-component-ids'
      out_file << writer.dump([RDF::Statement.new(
        res_uri, RDF::RDFS.seeAlso, GO["GO:#{ident}"])])
    elsif name == 'swissprot-accession-numbers'
      out_file << writer.dump([RDF::Statement.new(
        res_uri, RDF::RDFS.seeAlso, UNIPROT[ident])])
    elsif name == 'chebi-ids'
      out_file << writer.dump([RDF::Statement.new(
        res_uri, RDF::RDFS.seeAlso, CHEBI["CHEBI_#{ident}"])])
    elsif name == 'disease-ontology-ids'
      out_file << writer.dump([RDF::Statement.new(
        res_uri, RDF::RDFS.seeAlso, DO["DOID_#{ident}"])])
    end

    hash[uuid].each do |e|
      match_uri = RDF::URI(Addressable::URI.encode(N[e].to_s))
      out_file << writer.dump([RDF::Statement.new(
        res_uri, RDF::SKOS.exactMatch, match_uri)])
    end
  end
end

writer = RDF::Writer.for(:ntriples)
File.open("namespaces-skos.nt", "w") do |file|
  Dir['namespaces/*beleq'].each do |path|
    write_ns_stmts(hash, path, writer, file)
  end
end
