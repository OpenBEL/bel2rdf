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
  RELATIONSHIP_TYPE = {
    # 'actsIn' =>                 'actsIn',  XXX captured by belv:hasChild
      'analogous'              => 'analogous',
      'association'            => 'association',
      '--'                     => 'association',
      'biomarkerFor'           => 'biomarkerFor',
      'causesNoChange'         => 'causesNoChange',
      'decreases'              => 'decreases',
      '-|'                     => 'decreases',
      'directlyDecreases'      => 'directlyDecreases',
      '=|'                     => 'directlyDecreases',
      'directlyIncreases'      => 'directlyIncreases',
      '=>'                     => 'directlyIncreases',
      'hasComponent'           => 'hasComponent',
      'hasComponents'          => 'hasComponents',
      'hasMember'              => 'hasMember',
      'hasMembers'             => 'hasMembers',
      'hasModification'        => 'hasModification',
      'hasProduct'             => 'hasProduct',
      'hasVariant'             => 'hasVariant',
      'includes'               => 'includes',
      'increases'              => 'increases',
      '->'                     => 'increases',
      'isA'                    => 'isA',
      'negativeCorrelation'    => 'negativeCorrelation',
      'orthologous'            => 'orthologous',
      'positiveCorrelation'    => 'positiveCorrelation',
      'prognosticBiomarkerFor' => 'prognosticBiomarkerFor',
      'rateLimitingStepOf'     => 'rateLimitingStepOf',
      'reactantIn'             => 'reactantIn',
      'subProcessOf'           => 'subProcessOf',
      'transcribedTo'          => 'transcribedTo',
      ':>'                     => 'transcribedTo',
      '>>'                     => 'translatedTo',
      'translatedTo'           => 'translatedTo',
      'translocates'           => 'translocates'
  }
  # maps modification types to bel/vocabulary class
  MODIFICATION_TYPE = {
    "P,S" => BELV.PhosphorylationSerine,
    "P,T" => BELV.PhosphorylationTyrosine,
    "P,Y" => BELV.PhosphorylationThreonine,
    "A" =>BELV.Acetylation,
    "F" =>BELV.Farnesylation,
    "G" =>BELV.Glycosylation,
    "H" =>BELV.Hydroxylation,
    "M" =>BELV.Methylation,
    "P" =>BELV.Phosphorylation,
    "R" =>BELV.Ribosylation,
    "S" =>BELV.Sumoylation,
    "U" =>BELV.Ubiquitination
  }
  # pubmed URI
  PUBMED = 'http://bio2rdf.org/pubmed:'

  def self.for_statement(statement, writer)
    # TODO canonicalization

    case
    when statement.subject_only?
      id = for_term(statement.subject, writer)
      writer << [id, BELV.hasSubject, id]
    when statement.simple?
      sub_id = strip_prefix(for_term(statement.subject, writer))
      obj_id = strip_prefix(for_term(statement.object, writer))
      rel = RELATIONSHIP_TYPE[statement.rel.to_s]
      id = BELR["#{sub_id}_##{rel}_#{obj_id}"]
      writer << [id, BELV.hasSubject, sub_id]
      writer << [id, BELV.hasObject, obj_id]
      writer << [id, BELV.hasRelationship, RELATIONSHIP_TYPE[rel.to_s]]
    when statement.nested?
      sub_id  = strip_prefix(for_term(statement.subject, writer))
      nsub_id = strip_prefix(for_term(statement.object.subject, writer))
      nobj_id = strip_prefix(for_term(statement.object.object, writer))
      rel = RELATIONSHIP_TYPE[statement.rel.to_s]
      nrel = RELATIONSHIP_TYPE[statement.object.rel.to_s]
      id = BELR["#{sub_id}_#{rel}_#{nsub_id}_#{nrel}_#{nobj_id}"]
      nid = BELR["#{nsub_id}_#{nrel}_#{nobj_id}"]

      writer << [nid, RDF.type, BELV.Statement]
      writer << [nid, BELV.hasSubject, nsub_id]
      writer << [nid, BELV.hasObject, nobj_id]
      writer << [nid, BELV.hasRelationship, RELATIONSHIP_TYPE[nrel.to_s]]
      writer << [id, BELV.hasSubject, sub_id]
      writer << [id, BELV.hasObject, nid]
      writer << [id, BELV.hasRelationship, RELATIONSHIP_TYPE[rel.to_s]]
    end

    writer << [id, RDF.type, BELV.Statement]
    writer << [id, RDF::RDFS.label, statement.to_s]

    # evidence
    evidence_bnode = RDF::Node.new
    writer << [evidence_bnode, RDF.type, BELV.Evidence]
    writer << [id, BELV.hasEvidence, evidence_bnode]
    writer << [evidence_bnode, BELV.evidenceFor, id]

    # citation
    citation = statement.annotations.delete('Citation')
    value = citation.value.map{|x| x.gsub('"', '')}
    if citation and value[0] == 'PubMed'
      pid = value[2]
      writer << [evidence_bnode, BELV.hasCitation, RDF::URI(PUBMED + pid)]
    end

    # evidence
    evidence_text = statement.annotations.delete('Evidence')
    if evidence_text
      value = evidence_text.value.gsub('"', '')
      writer << [evidence_bnode, BELV.hasEvidenceText, value]
    end

    # annotations
    statement.annotations.each do |name, annotation|
      name = annotation.name.gsub('"', '')
      value = annotation.value.gsub('"', '')
      writer << [evidence_bnode, BELV.hasAnnotation, "#{name}:#{value}"]
    end

  end

  def self.for_term(term, writer)
    id = BELR[BELRDF::term_id(term)]

    # rdf:type
    writer << [id, RDF.type, BELV.Term]
    writer << [id, RDF.type, BELRDF::type(term)]

    # rdfs:label
    writer << [id, RDF::RDFS.label, term.to_s]

    # special proteins
    if term.fx == :p and term.args.find{|x| x.is_a? BEL::Script::Term and x.fx == :pmod}
      pmod = term.args.find{|x| x.is_a? BEL::Script::Term and x.fx == :pmod}
      mod_string = pmod.args.map(&:to_s).join(',')
      mod_type = MODIFICATION_TYPE.find {|k,v| mod_string.start_with? k}
      mod_type = (mod_type ? mod_type[1] : BELV.Modification)
      writer << [id, BELV.hasModificationType, mod_type]
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
        return BELV.ModifiedProteinAbundance
      end

      FUNCTION_TYPE[obj.fx.to_sym] || BELV.Abundance
    end
  end

  def self.term_id(term)
    term.to_s.squeeze(')').gsub(/[")]/, '').gsub(/[(:, ]/, '_')
  end

  def self.strip_prefix(uri)
    if uri.to_s.start_with? 'http://www.selventa.com/bel/'
      uri.to_s[28..-1]
    else
      uri
    end
  end

  def self.vocabulary_rdf
    [
      # Property
      [BELV.hasConcept, RDF.type, RDF.Property],
      [BELV.hasChild, RDF.type, RDF.Property],
      [BELV.hasSubject, RDF::RDFS.subPropertyOf, BELV.hasChild],
      [BELV.hasSubject, RDF::RDFS.range, BELV.Term],
      [BELV.hasSubject, RDF::RDFS.domain, BELV.Statement],
      [BELV.hasObject, RDF::RDFS.subPropertyOf, BELV.hasChild],
      [BELV.hasObject, RDF::RDFS.range, BELV.Term],
      [BELV.hasObject, RDF::RDFS.domain, BELV.Statement],
      [BELV.hasRelationship, RDF.type, RDF.Property],
      [BELV.hasModificationPosition, RDF.type, RDF.Property],
      [BELV.hasModificationType, RDF.type, RDF.Property],

      # Class
      [BELV.Term, RDF.type, RDF::RDFS.Class],
      [BELV.Statement, RDF.type, RDF::RDFS.Class],
      [BELV.Abundance, RDF.type, RDF::RDFS.Class],
      [BELV.Process, RDF.type, RDF::RDFS.Class],
      [BELV.ProteinAbundance, RDF::RDFS.subClassOf, BELV.Abundance],
      [BELV.ModifiedProteinAbundance, RDF::RDFS.subClassOf, BELV.ProteinAbundance],
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
      [BELV.AbundanceActivity, RDF::RDFS.subClassOf, BELV.Process],
      [BELV.Acetylation, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.Farnesylation, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.Glycosylation, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.Hydroxylation, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.Methylation, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.Phosphorylation, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.Ribosylation, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.Sumoylation, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.Ubiquitination, RDF::RDFS.subClassOf, BELV.Modification],
      [BELV.PhosphorylationSerine, RDF::RDFS.subClassOf, BELV.Phosphorylation],
      [BELV.PhosphorylationTyrosine, RDF::RDFS.subClassOf, BELV.Phosphorylation],
      [BELV.PhosphorylationThreonine, RDF::RDFS.subClassOf, BELV.Phosphorylation]
    ]
  end
end
