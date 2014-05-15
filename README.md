bel2rdf
=======

**Warning: This repository has been superseded by [OpenBEL/bel.rb](https://github.com/OpenBEL/bel.rb).**

Tool to convert BEL to RDF triples.

requirements
------------

* [ruby](https://www.ruby-lang.org/en/)
* gems
    * [bel.rb](https://github.com/OpenBEL/bel.rb) for parsing BEL.
    * [ruby-rdf/rdf](https://github.com/ruby-rdf/rdf) for writing RDF.

Optional tools:

* [raptop rdf](http://librdf.org/raptor/) - for converting between RDF formats
* [graphviz](http://www.graphviz.org/) - can convert DOT files converted using raptor

setup
-----

1. Install ruby.
2. Install bundler with `gem install bundler`.
3. Install required gems for bel2rdf with `bundle install`.

project layout
--------------

* [Gemfile](https://github.com/OpenBEL/bel2rdf/blob/master/Gemfile)
    * Describes gem dependencies for bel2rdf project.
* [vocabulary.rb](https://github.com/OpenBEL/bel2rdf/blob/master/vocabulary.rb)
    * Captures an RDF schema (RDFS) for the `BELV` vocabulary.
    * Maps BEL data to its RDF representation in the `BELV` vocabulary.
    * Provides functions that convert BEL objects to RDF.
* [conversion.rb](https://github.com/OpenBEL/bel2rdf/blob/master/conversion.rb)
    * Provides a writer for RDF-Turtle using the `rdf` gem.
* [bel2rdf.rb](https://github.com/OpenBEL/bel2rdf/blob/master/bel2rdf.rb)
    * Converts a BEL file (stdin or file path) to an RDF-Turtle file.
* [rdf_annotations.rb](https://github.com/OpenBEL/bel2rdf/blob/master/rdf_annotations.rb)
    * Converts the BEL annotation(`belanno`) files to SKOS RDF.
    * The `belanno` files to convert must be placed in an `annotations` directory relative to this file.
* [rdf_namespaces.rb](https://github.com/OpenBEL/bel2rdf/blob/master/rdf_namespaces.rb)
    * Converts the BEL namespace(`belns`) files to SKOS RDF.
    * The `belns` files to convert must be placed in an `namespaces` directory relative to this file.
* [rdf_orthology.rb](https://github.com/OpenBEL/bel2rdf/blob/master/rdf_orthology.rb)
    * Parses the [gene orthology](http://resource.belframework.org/belframework/1.0/resource/gene-orthology.bel) BEL file into RDF between namespace SKOS `Concepts`.

The [bel.ttl](https://github.com/OpenBEL/bel2rdf/blob/master/bel.ttl) provides RDF-Turtle for `BELV`'s RDF schema.  This is a slice of RDF data that will be included in the conversion.

running
-------

**Convert BEL to RDF**

```bash
./bel2rdf.rb full_abstract1.bel > full_abstract1.ttl
```

**Convert namespaces to SKOS vocabulary**

```bash
# copy belns files to namespaces/ directory
./rdf_namespaces.rb
```

**Convert annotations to SKOS vocabulary**

```bash
# copy belanno files to annotations/ directory
./rdf_annotations.rb
```

**Convert gene orthology to properties of the namespace SKOS Concepts**

```bash
./rdf_orthology.rb gene-orthology.bel
```

questions?
----------
Post questions to [OpenBEL discussion group](https://groups.google.com/forum/#!forum/openbel-discuss) and get immediate response from the community.
