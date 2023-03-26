#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COLUMNS = 3

def main
  files = []
  max_filename_width = 0
  is_option_a = option?('a')
  Dir.foreach('.') do |file|
    files << file if is_option_a || !file.match?(/^\./)
    max_filename_width = file.length if max_filename_width < file.length
  end
  display_files(files, max_filename_width + 4)
end

def option?(argument)
  ARGV.getopts(argument)[argument]
end

def split_files_by_row(files)
  number_rows = (files.size.to_f / COLUMNS).ceil
  files.sort.each_slice(number_rows).to_a.map { |row| row.values_at(0..number_rows - 1) }
end

def display_files(files, width)
  split_files_by_row(files).transpose.each do |rows|
    rows.each do |file|
      file = file.nil? ? '' : file
      print file.ljust(width)
    end
    puts
  end
end

main
