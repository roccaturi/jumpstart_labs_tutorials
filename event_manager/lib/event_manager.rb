require "date"
require "csv"
require "erb"
require "sunlight/congress"

Sunlight::Congress.api_key = "6afd465c747941829bbda56c4c730d17"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone(phone_number)
  phone_number.to_s
  ['-', '(', ')', ' ', '.'].each do |i|
    phone_number.gsub!(i, "")
  end
  if (phone_number.length > 11) || (phone_number.length < 10)
    nil
  elsif phone_number.length == 10
    phone_number
  elsif phone_number.length == 11
    phone_number[1..10]
  end
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letter(id, letter)
  Dir.mkdir("output") unless Dir.exists?("output")
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts letter
  end
end

def prepare_report(report)
  Dir.mkdir("output") unless Dir.exists?("output")
  File.open("output/internal_report.html", 'w') do |file|
    file.puts report
  end
end

def keys_by_value(value, assoc, output_array)
  puts "value: " + value.to_s
  puts "assoc:"
  klei = assoc.key(value)
  puts assoc.key(value)
  puts "output_array:"
  puts output_array.class
  if output_array.include?(klei)
    keys_by_value(value, assoc, output_array)
  else
    output_array << assoc.key(value)
  end
end

template_letter	 = File.read("form_letter.erb")
erb_template = ERB.new(template_letter)
template_report = File.read("internal_report.erb") 
erb_report = ERB.new(template_report)

contents = CSV.open("event_attendees.csv", headers: true, header_converters: :symbol)

hour_data = Hash.new(0)
weekday_data = Hash.new(0)

contents.each do |row|
  attendee_id = row[0]
  timestamp = DateTime.strptime(row[:regdate], "%m/%d/%Y %H:%M")
  hour_data[timestamp.hour] += 1
  weekday_data[timestamp.wday] += 1
  first_name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(attendee_id, form_letter)
end

puts hour_data.to_s
hour_totals = hour_data.values.sort {|a, b| b <=> a}
puts hour_totals[0]
puts hour_data.key(hour_totals[0])

hour_values = hour_data.values.sort {|a, b| b <=> a}
puts hour_values.to_s
ranked_hours = []
#hour_values.each {|value| keys_by_value(value, hour_data, ranked_hours)}
puts ranked_hours.to_s

form_report = erb_report.result(binding)
prepare_report(form_report)