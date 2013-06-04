require 'eldoorado'
require 'date'
require '../lib/txter/handler'
require '../lib/txter/converter'

module Txt
  def self.handle_txt_and_send_to_api(filename)
    txt = Handler.new("../data/#{filename}")
    txt.split_lines_into_params

    params = Converter.new(txt.valids)
    params.send_all_to_api
  end
end

Txt.handle_txt_and_send_to_api("may_badge_scans.txt")