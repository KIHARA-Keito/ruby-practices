#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  argv = ARGV
  params = setup_params(argv.getopts('clw'))
  row_data =
    if argv.empty?
      [$stdin.read].map { |data| build_status(params, data) }
    else
      argv.map do |path|
        file_name = File.open(path, 'r')
        file_content = file_name.read
        build_status(params, file_content, file_name, path)
      end
    end
  puts render(row_data, params)
end

def setup_params(options)
  params = { bytes: true, lines: true, words: true }
  if options['c'] || options['l'] || options['w']
    params[:bytes] = false unless options['c']
    params[:lines] = false unless options['l']
    params[:words] = false unless options['w']
  end
  params
end

def render(row_data, params)
  max_sizes = max_size_map(row_data)
  body = row_data.map { |data| format_body(data, params, max_sizes) }
  if row_data.size == 1
    body
  else
    totals = build_totals(row_data, params, max_sizes)
    [body, totals].join("\n")
  end
end

def build_status(params, file_content, file_name = nil, path = nil)
  file = file_name.nil? ? file_content : file_name
  row_data = {}
  row_data[:lines] = file_content.lines.count.to_s if params[:lines]
  row_data[:words] = file_content.split(/\s+|\n+|\t+/).size.to_s if params[:words]
  row_data[:bytesize] = file.size.to_s if params[:bytes]
  row_data[:filename] = path unless path.nil?
  row_data
end

def max_size_map(row_data)
  {
    lines: row_data.map { |data| data[:lines].to_s.size }.max,
    words: row_data.map { |data| data[:words].to_s.size }.max,
    bytesize: row_data.map { |data| data[:bytesize].to_s.size }.max
  }
end

def format_body(row_data, params, max_sizes)
  status = format_status(row_data, params, max_sizes)
  filename = row_data[:filename] if row_data[:filename]
  "#{status[:lines]}#{status[:words]}#{status[:bytesize]} #{filename}"
end

def build_totals(row_data, params, max_sizes)
  lines = params[:lines] ? 0 : nil
  words = params[:words] ? 0 : nil
  bytesize = params[:bytes] ? 0 : nil
  row_data.each do |data|
    lines += data[:lines].to_i if params[:lines]
    words += data[:words].to_i if params[:words]
    bytesize += data[:bytesize].to_i if params[:bytes]
  end
  format_totals(lines, words, bytesize, params, max_sizes)
end

def format_totals(lines, words, bytesize, params, max_sizes)
  row_data = { lines: lines.to_s, words: words.to_s, bytesize: bytesize.to_s }
  status = format_status(row_data, params, max_sizes)
  "#{status[:lines]}#{status[:words]}#{status[:bytesize]} total"
end

def format_status(row_data, params, max_sizes)
  lines = row_data[:lines].rjust(max_sizes[:lines] + 4) if params[:lines]
  words = row_data[:words].rjust(max_sizes[:words] + 4) if params[:words]
  bytesize = row_data[:bytesize].rjust(max_sizes[:bytesize] + 4) if params[:bytes]
  { lines:, words:, bytesize: }
end

main
