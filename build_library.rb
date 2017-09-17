require 'pry'
require './lib/library.rb'

library = Library.new

started_at = Time.now

library.build

finished_at = Time.now

puts
puts "Time: #{finished_at - started_at}"
puts "Errors: #{library.errors.size}"
puts "Tracks: #{library.size}"
