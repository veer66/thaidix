require "rexml/document"
require "pp"


if ARGV.length != 1
  $stderr.puts "Usage: ruby #{$0} <dix>"
  exit 1
end

entries = []
File.open(ARGV[0], "r:UTF-8") do |input_file|
  line_no = 0
  while input_file.gets
    line = $_.chomp
    if line =~ /^\s*<e/
      doc = REXML::Document.new(line)
      r_list = doc.get_elements("//r")
      if r_list.length != 1
        $stderr.puts "Invalid R"
        exit(1)
      end
      r = r_list[0]
      eng = r.text

      eng_s_node = r.get_elements("s")[0]
      
      if eng_s_node.nil?
        eng_tag = ""
      else
        eng_tag = eng_s_node.attribute("n").value
      end
      
      entry = {"orig" => line,
        "eng" => eng,
        "eng_tag" => eng_tag,
        "line_no" => line_no}
      entries << entry
    else
      if line =~ /<\/section/
        entries.sort! do |a,b| 
          if a["eng_tag"] == b["eng_tag"]
            if a["eng"] == b["eng"]
              a["line_no"] <=> b["line_no"]
            else
              a["eng"] <=> b["eng"]
            end
          else
            a["eng_tag"] <=> b["eng_tag"]
          end
        end

        prev_tag = nil
        entries.each do |e|
          if prev_tag != e["eng_tag"]
            puts "\n    <!-- #{e["eng_tag"]} -->"
            prev_tag = e["eng_tag"]
          end
          puts e["orig"]
        end
      end
      puts line
    end
    line_no =+ 1
  end
end
