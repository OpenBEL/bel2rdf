#!/usr/bin/env ruby
# vim: ts=2 sw=2:
# upgrade-annotations: Upgrade annotations for BEL file
#
# From BEL file
# usage: ruby upgrade-annotations.rb FILE.bel
# From standard in
# usage: echo "<BEL DOCUMENT STRING>" | ruby upgrade-annotations.rb
if __FILE__ == $0
  if ARGV[0]
    content = (File.exists? ARGV[0]) ? File.open(ARGV[0]).read : ARGV[0]
  else
    content = $stdin.read
  end

  require 'bel'
  require 'csv'
  class Main

    REMAP_FILE = 'remap.csv'
    TYPE_REMAP = {
      BodyRegion: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      CardiovascularSystem: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      Cell: ['Cell', 'http://resource.belframework.org/belframework/testing/annotation/cell.belanno'],
      CellLine: ['CellLine', 'http://resource.belframework.org/belframework/testing/annotation/cell-line.belanno'],
      CellStructure: ['CellStructure', 'http://resource.belframework.org/belframework/testing/annotation/cell-structure.belanno'],
      DigestiveSystem: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      Disease: ['Disease', 'http://resource.belframework.org/belframework/testing/annotation/disease.belanno'],
      CardiovascularSystem: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      FluidAndSecretion: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      HemicAndImmuneSystem: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      IntegumentarySystem: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      NervousSystem: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      RespiratorySystem: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      Tissue: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      UrogenitalSystem: ['Anatomy', 'http://resource.belframework.org/belframework/testing/annotation/anatomy.belanno'],
      Species: ['Species', 'http://resource.belframework.org/belframework/testing/annotation/species-taxonomy-id.belanno']
    }
    EvidenceMatcher = Regexp.compile(/SET Evidence = ([0-9a-zA-Z]+)/)

    attr_reader :ttl

    def initialize(content)
      unless File.readable? REMAP_FILE
        error_file(REMAP_FILE)
      end

      begin
        remap_file = File.open(REMAP_FILE)
        csv = CSV.new(remap_file, { row_sep: :auto })
        csv.reduce(@hash = {}) do |hash, row|
          old_type, old_val, new_type, new_val = row
          hash.store([old_type, old_val], [new_type, new_val])
          hash
        end
      ensure
        remap_file.close
      end

      BEL::Script.parse(content, ResourceIndex.openbel_published_index('20131211')) do |obj|
        if obj.is_a? Term or obj.is_a? Parameter
          return
        end

        if obj.is_a? AnnotationDefinition
          if TYPE_REMAP.include? obj.prefix.to_sym
            prefix, url = TYPE_REMAP[obj.prefix.to_sym]
            obj.prefix = prefix
            obj.value = url
          end
          puts obj.to_s
        elsif obj.is_a? Annotation
          if obj.name == 'Evidence'
            ev = obj.to_s
            ev.gsub!(EvidenceMatcher, 'SET Evidence = "\1"')
            puts ev
          elsif ['Citation', 'Species'].include? obj.name
            puts obj.to_s
          elsif obj.value.respond_to? :each
            # skip annotations that cannot be mapped or are already mapped
            unless TYPE_REMAP.include? obj.name.to_sym
              puts obj.to_s
              return
            end

            # handle value list
            name = TYPE_REMAP[obj.name.to_sym][0]
            values = obj.value.map do |v|
              if @hash.include? [name, v]
                @hash[[name, v]][1]
              else
                v
              end
            end
            obj.name = name
            obj.value = values
            puts obj.to_s
          elsif @hash.include? [obj.name, obj.value]
            new_type, new_val = @hash[[obj.name, obj.value]]
            obj.name = new_type
            obj.value = new_val
            puts obj.to_s
          else
            puts obj.to_s
          end
        elsif obj.is_a? Statement
          puts "#{obj.to_s}"
        else
          puts obj.to_s
        end
      end
    end

    private

    def error_file(file_name)
      $stderr.puts "#{file_name} is not readable"
      exit 1
    end
  end

  Main.new(content)
end
