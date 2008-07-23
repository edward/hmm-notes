#!/usr/bin/env ruby

states = ARGF.read.gsub(/\s+/,"")
window_size = 250

# Fake buffer at beginning and end.
#i_percent = states.scan(/I/).size/states.size.to_f
#buffer = (0..window_size).map { (rand < i_percent) ? "I" : "B" }.join
#states = buffer[0...(window_size/2)] + states + buffer[(window_size/2)..-1]

# Calculate percents for sliding window.
percents = (0..(states.size - window_size)).map do |i|
  states[i ,window_size].scan(/I/).size.to_f/window_size
end

puts percents.join(",")

