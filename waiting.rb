#!/usr/bin/env ruby

# change permissions on this file: chmod +x waiting.rb
# set an alias to this file as well
require 'yaml'
file = 'waiting.txt' # tip: set path to a Dropbox file for syncronized file across computers

### methods ###
def wait_file_exists(file)
	if FileTest.exist?(file)
		return true
	else
		return false
	end
end

def wait_file_read(file, readwrite)
	wait_file = YAML::load_stream(open(file))
	return wait_file
end

def passed_values(values)
	vals = {rand(999999) =>  { # checking for values just to have a sequential id order isn't worth the time
			'person' => values[1],
			'for' => values[3],
			'time_stamp' => Time.now.to_i,
			'status' => 1 # for future use, 1 will be active, 0 archived? other numbers, who knows
		}
	}
	return vals	
end

def plural(num) # converted from PHP written by jaytee http://snipplr.com/view/4912/relative-time/
	if num != 1
		return "s"
	end
end

def relative_time(timestamp) # converted from PHP written by jaytee http://snipplr.com/view/4912/relative-time/
	diff = Time.now.to_i - timestamp.to_i
	
	if diff < 60
		return diff.to_s + " second" +  plural(diff).to_s
	end

	diff = (diff/60).round
	if diff < 60
		return diff.to_s + " minute" +  plural(diff).to_s
	end
	
	diff = (diff/60).round
	if diff < 24
		return diff.to_s + " hour" +  plural(diff).to_s
	end
	
	diff = (diff/24).round
	if diff < 7
		return diff.to_s + " day" +  plural(diff).to_s
	end
	
	diff = (diff/7).round
	if diff < 4
		return diff.to_s + " week" +  plural(diff).to_s
	else
		return " " + timestamp.to_s
	end
end

def output_file(yml)
	i = 0
	if yml != nil
		puts ''
		puts 'You are waiting on the following:'
		max = yml.documents.count
		if max > 0
			while i < max do
				yml[i].each_key  { |key|
					id = key
					person = yml[i][key]['person']
					waitingfor = yml[i][key]['for']
					since = yml[i][key]['time_stamp']
					since = relative_time(since)
					puts "  #{person} to #{waitingfor} - #{since} [id:#{id}]"
				}
				i += 1
			end
			puts ''
		end
	else
		puts '  You\'re not waiting on anyone or anything'
	end
end

def wait_file_find(yml, string)
	i = 0
	max = yml.documents.count
	found = 0
	while i < max do
		yml[i].each_key { |key|
			if key == string.to_i
				found += 1
			end
		}
		i += 1
	end

	if found > 0
		return true
	else
		return false
	end
end

def wait_file_delete(yml, array_id)
	i = 0
	max = yml.documents.count
	while i < max do
		yml[i].each_key { |key|

			if key == array_id.to_i
				yml[i].delete(array_id.to_i)
			end
		}
		i += 1
	end
	return yml
end
### end methods ###


### control ###
if ARGV[0] == 'status' || ARGV.count == 0
	puts 'Waiting -  Copyright (C) 2011 Julio Garcia'
    puts 'This program comes with ABSOLUTELY NO WARRANTY;'
    puts 'This is free software, and you are welcome to redistribute it'
    puts 'under certain conditions;'
	puts ' '
    if wait_file_exists(file) == false
        puts 'You have not entered any information on anyone or anything'
    else
		wait_file = wait_file_read(file, 'r')
		output_file(wait_file)
	end
elsif ARGV[0] == 'for'
	puts 'You are waiting ' + ARGV[0] + ' ' + ARGV[1] + ' to ' + ARGV[3]
    if wait_file_exists(file) == false
		wait_file = wait_file_read(file, 'w+')
    else
		vals = passed_values(ARGV)
		wait_file = File.open(file, 'a+') do |f|
			f.write(vals.to_yaml)
		end
	end
elsif ARGV[0] == 'delete'
    if wait_file_exists(file) == false
        puts 'Error, no wait list file'
	elsif ARGV[1] == nil
		puts 'Error, need the id of what you want to delete'
    else
		wait_file = wait_file_read(file, 'r')
		if wait_file_find(wait_file, ARGV[1]) == false
			puts "Error, can't find an item with that id"
        else 
			vals = wait_file_delete(wait_file, ARGV[1])

			File.open(file, 'w+') do |clear|
				clear.write('')
			end
			
			i = 0
			max = vals.documents.count
			while i < max do
				new_wait_file = File.open(file, 'a+') do |f|
					if vals.documents[i].to_yaml != "--- {}\n\n"
						f.write(vals.documents[i].to_yaml)
					end
				end
				i += 1
			end
			puts "Deleted"
		end
	end
elsif ARGV[0] == 'version' || ARGV[0] == '-v'
	puts 'Waiting 0.1 -  Copyright (C) 2011 Julio Garcia'
    puts 'This program comes with ABSOLUTELY NO WARRANTY;'
    puts 'This is free software, and you are welcome to redistribute it'
    puts 'under certain conditions;'
elsif ARGV[0] == 'options'
	puts 'To start tracking someone, type: for <name> to "<action>"'
	puts '- keep <action> in quotes, <name> should be in quotes for multiple people'
	puts 'ex. ./waiting.rb for Julio to "finish writing his README"'
	puts ''
	puts 'To delete, type: delete <id>'
	puts 'ex. ./waiting.rb delete 392'
	puts ''
	puts 'To view status of what you\'re waiting on, simply type: status'
else
    puts 'error'
end