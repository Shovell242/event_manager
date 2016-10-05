require "csv"


def clean_zipcode(zipcode)

event_file = "event_attendees.csv"

contents = CSV.open(event_file, headers: true, header_converters: :symbol) 

contents.each do |row|
	puts row[:Zipcode]
end




