require 'rspotify'
require 'active_support/all'
require 'pry'
require 'json'
require 'yaml'
require 'args_parser'
require './lib/library.rb'

$config = YAML.load_file 'config.yml'

TEMPLATE = 'template.html.erb'
OUTPUT = 'results.html'

def authenticate
  RSpotify.authenticate(
    $config['spotify']['client_id'],
    $config['spotify']['client_secret']
  )
end

def get_playlist(name)
  user = RSpotify::User.find($config['spotify']['username'])
  user.playlists.find { |p| p.name == name }
end

def convert_ms_to_time_format(ms)
  Time.at(ms / 1000).utc.strftime("%H:%M:%S")
end

library = Library.new $config['tunes_dir']

args = ArgsParser.parse ARGV do
  arg :output, 'output file', alias: :o, default: OUTPUT
  arg :template, 'template file', alias: :t, default: TEMPLATE
  arg :playlist, 'spotify playlist name', alias: :p
  arg :build, 'build library', alias: :b
  arg :search, 'search library', alias: :s
  arg :verbose, 'more output', alias: :v
end

if args.has_param? :search
  results = library.search title: args[:search]
  results['hits']['hits'].each do |hit|
    source = hit['_source']
    puts "#{hit['_score']} - #{source['title']} - #{source['artist']} - #{source['album']}"
    puts hit if args.has_option? :verbose
  end
end

if args.has_option? :build
  started_at = Time.now
  library.build
  finished_at = Time.now

  puts
  puts "Time: #{finished_at - started_at}"
  puts "Errors: #{library.errors.size}"
  puts "Tracks: #{library.size}"
  exit 1
end

if args.has_param? :playlist
  authenticate
  playlist = get_playlist args[:playlist]

  rows = []
  template = File.read(args[:template])
  File.delete(args[:output]) if File.exists?(args[:output])

  playlist.tracks.each do |track|
    dupes = library.search(title: track.name, artist: track.artists.first.name)['hits']['hits']

    rows << {
      preview_url: track.preview_url,
      playlist: playlist.name,
      track_name: track.name,
      artists: track.artists.map(&:name),
      duration: convert_ms_to_time_format(track.duration_ms),
      album: {
        name: track.album.name,
        image: track.album.images.find { |i| i['height'] == 64 }.try(:[], 'url')
      },
      amazon_url: "https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Ddigital-music&field-keywords=#{URI.escape("#{track.name} #{track.artists.first.name}")}",
      beatport_url: "https://www.beatport.com/search?q=#{URI.escape(track.name)}",
      spotify_url: track.external_urls['spotify'],
      soundcloud_url: "https://soundcloud.com/search?q=#{URI.escape(track.name)}",
      dupes: dupes.map { |dupe|
        {
          score: dupe['_score'],
          filename: dupe['_source']['filename'],
          path: dupe['_source']['path'],
          duration: convert_ms_to_time_format(dupe['_source']['duration'] * 1000),
          title: dupe['_source']['title'],
          artist: dupe['_source']['artist'],
          album: dupe['_source']['album'],
        }
      },
    }

    File.open(OUTPUT, "w") { |f| f.write(ERB.new(template).result(binding)) }
    print '.'
  end

  `open #{args[:output]}`
end
