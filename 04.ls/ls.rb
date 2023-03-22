#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMNS = 3

def main
  files = []
  max_filename_width  = 0
  Dir.each_child('.') do |file|
    files << file unless file.match?(/^\./)
    max_filename_width  = file.length if max_filename_width  < file.length
  end
  two_dimensional_files = divide_into_rows(files)
  sorted_files = flatten_set_empty(two_dimensional_files)
  display_files(sorted_files, max_filename_width  + 4)
end

def divide_into_rows(files)
  number_rows = (files.size.to_f / COLUMNS).ceil
  files.sort.each_slice(number_rows).to_a.map { |row| row.values_at(0..number_rows - 1) }
end

def flatten_nil_empty(files)
  files.transpose.flatten.map { |file| file.nil? ? '' : file }
end

def display_files(files, width)
  files.each.with_index(1) do |file, index|
    print file.ljust(width)
    puts if (index % COLUMNS).zero?
  end
end

main
