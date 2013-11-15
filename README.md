bel2rdf
=======

Tool to convert BEL to RDF triples.

Requirements:

* [bel.rb](https://github.com/OpenBEL/bel.rb) for parsing BEL.
* [ruby-rdf/rdf](https://github.com/ruby-rdf/rdf) for writing RDF.

development toolchain
---------------------

Requirements:

* [raptop rdf](http://librdf.org/raptor/)
* [graphviz](http://www.graphviz.org/)
* something to view an image file

```bash
# convert BEL to RDF turtle
./bel2rdf.rb full_abstract1.bel > full_abstract1.ttl

# convert RDF turtle to graphviz DOT language
# then render as a PNG image
rapper -i turtle -o dot full_abstract1.ttl | dot -Tpng -o full_abstract1.png

# view image; for example feh
feh full_abstract1.png
```
