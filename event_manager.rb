require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phonenumber(number)
	all_nums = number.to_s.scan(/\d+/).join

	if all_nums.length < 10 || all_nums.length > 11 || (all_nums.length == 11 && all_nums[0] != "1")
		"Bad number"
	elsif all_nums.length == 11 && all_nums[0] == "1"
		all_nums[1..-1]
	else
		all_nums
	end
end
		
def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, letter)
	Dir.mkdir("output") unless Dir.exists?("output")
	filename = "output/thanks_#{id}.html"

	File.open(filename, "w") { |file| file.puts letter }
end

def parse_hour(time)
	format = "%m/%d/%y %H:%M"

	parse = DateTime.strptime(time, format)

	parse.hour
end

def time_histogram(data)
	hash = data.reduce(Hash.new(0)) do |hsh, row|
				 	hsh[parse_hour(row[:regdate])] += 1
				 	hsh
				 end

	sorted = hash.sort_by { |k, v| k }

	sorted.each { |k, v| puts "Hour:#{k} - Freq:#{v}" }
end

event_file = "event_attendees.csv"

contents = CSV.open(event_file, headers: true, header_converters: :symbol) 

template_letter = File.read("form_letter.erb")
erb_template    = ERB.new(template_letter)

contents.each do |row|
	id    = row[0]
	name  = row[:first_name]
	regdate = row[:regdate]
	
	zipcode     = clean_zipcode(row[:zipcode])
	legislators = legislators_by_zipcode(zipcode)
	form_letter = erb_template.result(binding)

	save_thank_you_letters(id, form_letter)
end





