module Txt
  class Handler
    attr_reader :filename, :lines, :invalids, :valids
    DOORS = ['Atrium Door (In)', 'Back Door (In)', 'Knoll Door (In)', 'Front Door (In)']

    def initialize(filename)
      @filename = filename
      contents = self.open
      @lines = contents.gsub("\t", " ").gsub("\r", " ").split("\n")
      @valids = []
      @invalids = []
    end

    def open
      file = File.open(filename, "rb")
      file.read
    end

    def split_lines_into_params
      return if @valids.count > 0

      puts "Parsing TXT file. Converting to array."
      lines.collect do |line|
        begin
          split = line.split("Access permitted - token only")
          first_section = split[0].split(" ")
          second_section = split[1].split(" ")

          scan_time = first_section[0..2].join(" ")
          first_name = first_section[3..-1].join(" ").split(",")[-1]
          last_name = first_section[3..-1].join(" ").split(",")[0]
          door = second_section[-3..-1].join(" ")
          company = second_section.join(" ").gsub(door, "")

          valids << [scan_time, first_name, last_name, door, company].collect {|l| Handler.remove_whitespace l}
        rescue
          invalids << line
        end
      end
      puts "Parse complete. #{valids.count} valid badge scans and #{invalids.count} invalid badge scans."
    end

    def self.remove_whitespace(line)
      line.rstrip.lstrip
    end
  end
end

