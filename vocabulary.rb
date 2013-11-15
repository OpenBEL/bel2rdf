# vim: ts=2 sw=2:
# Defines the RDF vocabulary for BEL structures.

require 'rdf'
require 'bel'

module BELRDF
  BELR    = RDF::Vocabulary.new("http://www.selventa.com/bel/")
  BELV    = RDF::Vocabulary.new("http://www.selventa.com/vocabulary/")
  HGNC    = RDF::Vocabulary.new("http://www.selventa.com/entity/hgnc-approved-symbols/")
  MGI     = RDF::Vocabulary.new("http://www.selventa.com/entity/mgi-approved-symbols/")
  RGD     = RDF::Vocabulary.new("http://www.selventa.com/entity/rgd-approved-symbols/")
  MESHCL  = RDF::Vocabulary.new("http://www.selventa.com/entity/mesh-cellular-locations/")
  SFAM    = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-protein-families/")
  CHEBI   = RDF::Vocabulary.new("http://www.selventa.com/entity/chebi-names/")
  NCH     = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-named-complexes-human/")
  NCM     = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-named-complexes-mouse/")
  NCR     = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-named-complexes-rat/")
  PFH     = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-protein-families-human/")
  PFM     = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-protein-families-mouse/")
  PFR     = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-protein-families-rat/")
  GO      = RDF::Vocabulary.new("http://www.selventa.com/entity/go/")
  MESHPP  = RDF::Vocabulary.new("http://www.selventa.com/entity/mesh-processes/")
  MESHD   = RDF::Vocabulary.new("http://www.selventa.com/entity/mesh-diseases/")
  EGID    = RDF::Vocabulary.new("http://www.selventa.com/entity/entrez-gene/")
  SCHEM   = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-protein-families-human/")
  SDIS    = RDF::Vocabulary.new("http://www.selventa.com/entity/selventa-legacy-diseases/")
  GOCCACC = RDF::Vocabulary.new("http://www.selventa.com/entity/go-cellular-components/")


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
    deg: BELV.Degradation,
    cat: BELV.AbundanceActivity,
    chap: BELV.AbundanceActivity,
    gtp: BELV.AbundanceActivity,
    kin: BELV.AbundanceActivity,
    act: BELV.AbundanceActivity,
    pep: BELV.AbundanceActivity,
    phos: BELV.AbundanceActivity,
    ribo: BELV.AbundanceActivity,
    tscript: BELV.AbundanceActivity,
    tport: BELV.AbundanceActivity
  }
  # maps modification types to bel/vocabulary class
  MODIFICATION_TYPE = {
    "P,S" => BELV.PhosphorylationSerineProteinAbundance,
    "P,T" => BELV.PhosphorylationTyrosineProteinAbundance,
    "P,Y" => BELV.PhosphorylationThreonineProteinAbundance,
    "A" =>BELV.AcetylationProteinAbundance,
    "F" =>BELV.FarnesylationProteinAbundance,
    "G" =>BELV.GlycosylationProteinAbundance,
    "H" =>BELV.HydroxylationProteinAbundance,
    "M" =>BELV.MethylationProteinAbundance,
    "P" =>BELV.PhosphorylationProteinAbundance,
    "R" =>BELV.RibosylationProteinAbundance,
    "S" =>BELV.SumoylationProteinAbundance,
    "U" =>BELV.UbiquitinationProteinAbundance
  }

  def self.for_term(term, writer)
    id = BELR[BELRDF::term_id(term)]

    # rdf:type
    writer << [id, RDF.type, BELRDF::type(term)]

    # special proteins
    if term.fx == :p and term.args.find{|x| x.is_a? BEL::Script::Term and x.fx == :pmod}
      pmod = term.args.find{|x| x.is_a? BEL::Script::Term and x.fx == :pmod}
      last = pmod.args.last.to_s
      if last.match(/^\d+$/)
        writer << [id, BELV.hasModificationPosition, last.to_i]
      end
    end

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
      if obj.fx == :p and obj.args.find{|x| x.is_a? BEL::Script::Term and x.fx == :pmod}
        pmod = obj.args.find{|x| x.is_a? BEL::Script::Term and x.fx ==:pmod}
        mod_string = pmod.args.map(&:to_s).join(',')
        mod_type = MODIFICATION_TYPE.find {|k,v| mod_string.start_with? k}
        return mod_type ? mod_type[1] : BELV.ModifiedProteinAbundance
      end

      FUNCTION_TYPE[obj.fx.to_sym] || BELV.Abundance
    end
  end

  def self.term_id(term)
    term.to_s.squeeze(')').gsub(/[")]/, '').gsub(/[(:, ]/, '_')
  end

  def self.vocabulary_rdf
    [
      [BELV.ProteinAbundance, RDF::RDFS.subClassOf, BELV.Abundance],
      [BELV.ModifiedProteinAbundance, RDF::RDFS.subClassOf, BELV.ProteinAbundance],
      [BELV.AcetylationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.FarnesylationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.GlycosylationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.HydroxylationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.MethylationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.PhosphorylationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.RibosylationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.SumoylationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.UbiquitinationProteinAbundance, RDF::RDFS.subClassOf, BELV.ModifiedProteinAbundance],
      [BELV.PhosphorylationSerineProteinAbundance, RDF::RDFS.subClassOf, BELV.PhosphorylationProteinAbundance],
      [BELV.PhosphorylationTyrosineProteinAbundance, RDF::RDFS.subClassOf, BELV.PhosphorylationProteinAbundance],
      [BELV.PhosphorylationThreonineProteinAbundance, RDF::RDFS.subClassOf, BELV.PhosphorylationProteinAbundance],
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
