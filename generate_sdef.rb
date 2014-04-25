require "rexml/document"
require "pp"

def read_apertium_symbol
  symtab = Hash.new("")

  File.open("apertium_symbol.txt") do |file|
    file.each_with_index do |line, i|
      if line.strip =~ /^(\w+)\s+(.+)$/
        symtab[$1] = $2
      end
    end
  end
  
  return symtab
end

def main
  if ARGV.length != 1
    $stderr.puts "Usage: ruby #{$0} <dix>"
    exit 1
  end
  
  symtab = read_apertium_symbol

  existing_symbols = {}
  File.open(ARGV[0], "r:UTF-8") do |file|
    file.each do |line|
      if line =~ /^\s*<e/
        REXML::Document.new(line).each_element("//s") do |s|
          sym = s.attribute("n").value
          existing_symbols[sym] = 1
        end
      end
    end
  end

  sym_list = existing_symbols.keys.sort 
  
  sym_list.each do |sym|
    comment = symtab[sym]
    puts "<sdef n=#{sym.encode(:xml => :attr)} "+ 
      "c=#{comment.encode(:xml => :attr)}/>"
  end
end

main

