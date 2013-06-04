module Txt
  class Converter
    attr_accessor :badge_scans
    MAX_ATTEMPTS = 3

    def initialize(valid_scans)
      @badge_scans = valid_scans
    end

    def send_all_to_api
      puts "Sending to Eldoorado GEM"
      badge_scans.each_with_index do |badge_scan, i|
        Converter.attempt_send_to_api(badge_scan)
        puts "Scan #{i+1} created."
      end
    end

    def self.write_failure_to_file(failure)
      File.open("../data/failed_scans.txt", "a") do |file|
        file.write "#{failure},"
      end
    end

    def self.attempt_send_to_api(badge_scan)
      @failed_scans = []
      limiter = 0
      begin
        handle_params badge_scan
      rescue
        limiter += 1
        if limiter <= MAX_ATTEMPTS
          puts "Retry number #{limiter}."
          retry
        else
          puts "Scan failed."
          write_failure_to_file(badge_scan)
        end
      end
    end

    def self.assign_variables(array)
      [array[0], array[1], array[2], get_door_id(array[3]), array[4]]
    end

    def self.handle_params(badge_scan)
      scan_time, first_name, last_name, door_id, company_name = assign_variables(badge_scan)

      company_id = get_company(company_name).id
      entrant_id = get_entrant(first_name, last_name, company_id).id
      create_badge_scan(entrant_id, door_id, scan_time)
    end

    def self.get_door_id(location)
      {"Atrium Door (In)" => 1, "Back Door (In)" => 2, "Knoll Door (In)" => 3, "Front Door (In)" => 4}[location]
    end

    def self.get_company(company_name)
      Eldoorado::Company.create(name: company_name)
    end

    def self.get_entrant(first_name, last_name, company_id)
      Eldoorado::Entrant.create(
        first_name: first_name,
        last_name: last_name,
        company_id: company_id)
    end

    def self.create_badge_scan(entrant_id, door_id, scan_time)
      Eldoorado::BadgeScan.create(
        scan_time: DateTime.strptime(scan_time, "%m/%d/%Y %l:%M:%S %p"),
        entrant_id: entrant_id,
        door_id: door_id)      
    end
  end
end

