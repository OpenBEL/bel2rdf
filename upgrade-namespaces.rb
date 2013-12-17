#!/usr/bin/env ruby
# vim: ts=2 sw=2:
# upgrade-namespaces: Upgrade namespaces for BEL file given a change log.
#
# From BEL file
# usage: ruby upgrade-namespaces.rb -b file.bel -c file.json
# From standard in
# usage: echo "<BEL DOCUMENT STRING>" | ruby upgrade-namespaces.rb -c file.json
if __FILE__ == $0
  require 'optparse'

  # setup and parse options
  options = {}
  op = OptionParser.new do |opts|
    opts.banner = "Usage: upgrade-namespaces.rb [options] [.bel file]"
    opts.on('-b', '--bel BEL_FILE', 'BEL file to upgrade.  STDIN (standard in) can also be used for BEL content.') do |bel|
      options['bel'] = bel
    end
    opts.on("-c", "--change-log JSON_FILE", "Change log file") do |change_log|
      options['change_log'] = change_log
    end
  end.parse!

  # option guards
  unless options['change_log']
    $stderr.puts "Missing --change-log option. Use -h / --help for details."
    exit
  end
  unless options['bel'] or not STDIN.tty?
    $stderr.puts "No bel content provided.  Either use --bel option or STDIN (standard in).  Use -h / --help for details." 
    exit
  end
  if not File.exists? options['change_log']
    $stderr.puts "No file for change_log, #{options['change_log']}"
    exit
  end
  if options['bel'] and not File.exists? options['bel']
    $stderr.puts "No file for bel, #{options['bel']}"
    exit
  end

  # read bel content
  content = (STDIN.tty?) ? File.open(options['bel']).read : $stdin.read

  require 'bel'
  require 'json'
  class Main

    NonWordMatcher = Regexp.compile(/[^0-9a-zA-Z]/)
    attr_reader :ttl

    def initialize(content, change_log)
      begin
        changelog_file = File.open(change_log)
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
              $stderr.puts "no replacement value for #{obj.ns} '#{obj.value}' - value '#{replacement}'"
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

      puts obj.to_s
    end

    private

    def error_file(file_name)
      $stderr.puts "#{file_name} is not readable"
      exit 1
    end
  end

  prog = Main.new(content, options['change_log'])
end
