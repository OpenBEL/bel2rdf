# vim: ts=2 sw=2:
# Defines the RDF vocabulary for BEL structures.

require 'rdf'
require 'bel'

module BELRDF
  BELR   = RDF::Vocabulary.new("http://www.selventa.com/bel/")
  BELV   = RDF::Vocabulary.new("http://www.selventa.com/vocabulary/")
  HGNC   = RDF::Vocabulary.new("http://www.selventa.com/entity/hgnc-approved-symbols/")
  MESHCL = RDF::Vocabulary.new("http://www.selventa.com/entity/mesh-cellular-locations/")
  SFAM   = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-protein-families/")
  CHEBI  = RDF::Vocabulary.new("http://www.selventa.com/entity/chebi-names/")

  # maps outer function to bel/vocabulary class
  FUNCTION_TYPE = {
    a: BELV.Abundance,
    g: BELV.GeneAbundance,
    p: BELV.ProteinAbundance,
    r: BELV.RNAAbundance,
    m: BELV.microRNAAbundance,
    complex: BELV.ComplexAbundance,
    composite: BELV.CompositeAbundance,
    bp: BELV.BiologicalProcess,
    path: BELV.Pathology,
    rxn: BELV.Reaction,
    tloc: BELV.Translocation,
    sec: BELV.CellSecretion,
    deg: BELV.Degradation
  }

  def self.for_term(term, writer)
    id = BELR[BELRDF::term_id(term)]

    # rdf:type
    writer << [id, RDF.type, BELRDF::type(term)]

    # belv:hasConcept
    term.args.find_all{|x| x.is_a? BEL::Script::Parameter}.each do |concept|
      if concept.ns and const_get concept.ns
        ev = const_get concept.ns
        value = concept.value.gsub(' ', '_').gsub('"', '')
        writer << [id, BELV.hasConcept, ev[value]]
      end
    end

    # belv:hasChild
    term.args.find_all{|x| x.is_a? BEL::Script::Term}.each do |child|
      child_id = self.for_term(child, writer)
      writer << [id, BELV.hasChild, child_id]
    end

    return id
  end

  def self.type(obj)
    if obj.respond_to? 'fx'
      FUNCTION_TYPE[obj.fx.to_sym] || BELV.Abundance
    end
  end

  def self.term_id(term)
    term.to_s.squeeze(')').gsub(/[",)]/, '').gsub(/[(:, ]/, '_')
  end

  def self.vocabulary_rdf
    [
      [BELV.ProteinAbundance, RDF::RDFS.subClassOf, BELV.Abundance],
      [BELV.ModifiedProteinAbundance, RDF::RDFS.subClassOf, BELV.ProteinAbundance],
      [BELV.PhosphoProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.PhosphoSerineProteinAbundance, RDF::RDFS.subClassOf, BELV.PhosphoProteinAbundance],
      [BELV.PhosphoTyrosineProteinAbundance, RDF::RDFS.subClassOf, BELV.PhosphoProteinAbundance],
      [BELV.PhosphoThreonineProteinAbundance, RDF::RDFS.subClassOf, BELV.PhosphoProteinAbundance],
      [BELV.ProteinVariantAbundance, RDF::RDFS.subClassOf, BELV.ProteinAbundance],
      [BELV.ComplexAbundance, RDF::RDFS.subClassOf, BELV.Abundance],
      [BELV.CompositeAbundance, RDF::RDFS.subClassOf, BELV.Abundance],
      [BELV.RNAAbundance, RDF::RDFS.subClassOf, BELV.Abundance],
      [BELV.GeneAbundance, RDF::RDFS.subClassOf, BELV.Abundance],
      [BELV.microRNAAbundance, RDF::RDFS.subClassOf, BELV.Abundance],
      [BELV.BiologicalProcess, RDF::RDFS.subClassOf, BELV.Process],
      [BELV.Pathology, RDF::RDFS.subClassOf, BELV.BiologicalProcess],
      [BELV.Transformation, RDF::RDFS.subClassOf, BELV.Process],
      [BELV.Reaction, RDF::RDFS.subClassOf, BELV.Transformation],
      [BELV.Translocation, RDF::RDFS.subClassOf, BELV.Transformation],
      [BELV.CellSecretion, RDF::RDFS.subClassOf, BELV.Translocation],
      [BELV.Degradation, RDF::RDFS.subClassOf, BELV.Transformation],
      [BELV.AbundanceActivity, RDF::RDFS.subClassOf, BELV.Process]
    ]
  end
end
