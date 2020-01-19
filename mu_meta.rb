# frozen_string_literal: true

require './allmusic.rb'
require 'optparse'
require 'json'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: mu_meta.rb [options]'
  opts.on('-d', '--dir PATH', 'Path to local album directory with' \
          'files in correct track order') do |o|
            options[:music_dir] = o
          end
  opts.on('-q', '--query QUERY', 'Query for finding AllMusic album data') do |o|
    options[:query] = o
  end
  options[:help] = opts.help
end.parse!

if options.values_at(:music_dir, :query).map { |arg| arg.to_s.empty? }
          .include?(true)
  puts options[:help]

  puts "\nArgs missing!"
  return
end

album_data = AllMusic.new.album(options[:query])
local_tracks = Dir.glob("#{options[:music_dir]}/*.mp3").sort.map do |el|
  el.split('/').last.split('.mp3').first
end
album_data[:tracks] = album_data[:songs].map.with_index(0) do |song, index|
  { name: song, id: local_tracks[index] }
end
album_data.delete :songs

File.open("./#{album_data[:title]}.json", 'w') do |f|
  f.write(JSON.pretty_generate(album_data))
end
