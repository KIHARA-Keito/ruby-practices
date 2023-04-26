#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

COLUMNS = 3
COLUMNS_GUTTER = 4

def main
  options = ARGV.getopts('arl')
  files = []
  max_filename_width = 0
  Dir.foreach('.') do |file|
    files << file if options['a'] || !file.match?(/^\./)
    max_filename_width = file.length if max_filename_width < file.length
  end
  files_sorted = options['r'] ? files.sort.reverse : files.sort
  if options['l']
    display_one_line(files_sorted)
  else
    display_multiple_lines(files_sorted, max_filename_width)
  end
end

def split_files_by_row(files)
  number_rows = (files.size.to_f / COLUMNS).ceil
  files.each_slice(number_rows).to_a.map { |row| row.values_at(0..number_rows - 1) }
end

def display_multiple_lines(files, width)
  width += COLUMNS_GUTTER
  split_files_by_row(files).transpose.each do |rows|
    rows.each do |file|
      file = file.nil? ? '' : file
      print file.ljust(width)
    end
    puts
  end
end

def display_one_line(files)
  max_filesize_width = 0
  file_blocks = 0
  files.each do |file|
    file_length = File.stat(file).size.to_s.length
    max_filesize_width = file_length if max_filesize_width < file_length
    file_blocks += File.stat(file).blocks
  end
  puts "total #{file_blocks}"
  files.each do |file|
    puts file_status_join(file, max_filesize_width)
  end
end

def file_status_join(file, width)
  file_stat = File.stat(file)
  mode = file_mode(file_stat.mode.to_s(8).rjust(6, '0'))
  link = file_stat.nlink.to_s.rjust(2)
  user = Etc.getpwuid(file_stat.uid).name
  group = Etc.getgrgid(file_stat.gid).name
  size = file_stat.size.to_s.rjust(width + 1)
  time = file_stat.mtime.strftime('%_m %_d %R')
  "#{mode} #{link} #{user} #{group} #{size} #{time} #{file}"
end

def file_mode(mode)
  type = file_type(mode.slice(0..1))
  owner =
    if mode.slice(2) == '4'
      permission_replace(file_authority(mode.slice(3)), 's')
    else
      file_authority(mode.slice(3))
    end
  owner_group =
    if mode.slice(2) == '2'
      permission_replace(file_authority(mode.slice(4)), 's')
    else
      file_authority(mode.slice(4))
    end
  etc =
    if mode.slice(2) == '1'
      permission_replace(file_authority(mode.slice(5)), 't')
    else
      file_authority(mode.slice(5))
    end
  "#{type}#{owner}#{owner_group}#{etc}"
end

def file_type(number)
  {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }[number]
end

def file_authority(number)
  {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[number]
end

def permission_replace(mode, permission)
  case mode.slice(-1)
  when 'x'
    mode.sub(/x$/, permission)
  when '-'
    mode.sub(/-$/, permission.upcase)
  end
end

main
