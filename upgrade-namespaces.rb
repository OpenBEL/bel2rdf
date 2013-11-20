#!/usr/bin/env ruby
# vim: ts=2 sw=2:
# upgrade-namespaces: Upgrade namespaces for BEL file
#
# From BEL file
# usage: ruby upgrade-namespaces.rb FILE.bel
# From standard in
# usage: echo "<BEL DOCUMENT STRING>" | ruby upgrade-namespaces.rb
if __FILE__ == $0
  if ARGV[0]
    content = (File.exists? ARGV[0]) ? File.open(ARGV[0]).read : ARGV[0]
  else
    content = $stdin.read
  end

  require 'bel'
  require 'json'
  class Main

    CHANGELOG_FILE = 'change_log.json'
    NonWordMatcher = Regexp.compile(/[^0-9a-zA-Z]/)

    attr_reader :ttl

    def initialize(content)
      unless File.readable? CHANGELOG_FILE
        error_file(CHANGELOG_FILE)
      end

      begin
        changelog_file = File.open(CHANGELOG_FILE)
        @clog = JSON.parse(changelog_file.read)
      ensure
        changelog_file.close
      end

      parser = BEL::Script::Parser.new
      parser.add_observer self
      parser.parse(content)
    end
    def update(obj)
      if obj.is_a? BEL::Script::Parameter
        if @clog.has_key? obj.ns
          clog_ns = @clog[obj.ns]
          if clog_ns.has_key? obj.value
            replacement = clog_ns[obj.value]
            if replacement == 'unresolved' or replacement == 'withdrawn'
              $stderr.puts "replace, '#{obj.value}' for '#{replacement}'"
              return
            end
            obj.value = replacement
          end
        end
        return
      end

      if obj.is_a? BEL::Script::Term
        return # do not print (part of statement)
      end

      if obj.is_a? BEL::Script::Statement
        puts "#{obj.to_s}\n\n"
        return
      end

      puts obj.to_s
    end

    private

    def error_file(file_name)
      $stderr.puts "#{file_name} is not readable"
      exit 1
    end
  end

  prog = Main.new(content)
end
