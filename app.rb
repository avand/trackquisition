require 'rspotify'
require 'active_support/all'
require 'pry'
require 'json'
require 'yaml'

$spotify = YAML.load_file 'spotify.yml'
TUNES_DIR = '~/Dropbox/Tunes'
TEMPLATE = 'template.html.erb'
RESULTS = 'results.html'
CACHE_TTL = 3.days
CACHE_TIME_PREFIX_FORMAT = '%Y%m%d'

class Dupe
  attr_accessor :filename, :path, :duration, :metadata, :album

  def initialize(path)
    @path = path
    @filename = File.basename(path)
  end

  def metadata
    @metadata ||= `ffmpeg -i "#{path}" 2>&1`
  end

  def duration
    metadata.match(/Duration: (\d{2}:\d{2}:\d{2}\.\d{2})/)[1]
  end

  def method_missing(symbol)
    metadata.match(/#{symbol}\s*:(.*)/).try(:[], 1).try(:strip)
  end
end

def authenticate
  RSpotify.authenticate($spotify['client_id'], $spotify['client_secret'])
end

def get_playlists
  user = RSpotify::User.find($spotify['username'])
  user.playlists.select { |p| p.name.in? ARGV }
end

def find_dupes(query)
  cache = "cache/#{Time.now.strftime(CACHE_TIME_PREFIX_FORMAT)}#{query}"

  paths = if File.exists?(cache)
    File.read(cache)
  else
    output = `mp3find #{TUNES_DIR} -i -title \"#{query}\" 2> /dev/null`
    output += `find #{TUNES_DIR} -iname "*#{query}*" -type f`
    File.open(cache, "w") { |f| f.write(output) }
    output
  end.split("\n").uniq

  paths.map { |p| Dupe.new(p) }
end

def cleanup_old_cache
  cutoff = CACHE_TTL.ago.strftime(CACHE_TIME_PREFIX_FORMAT).to_i

  Dir.glob("cache/*").each do |cache|
    match = cache.match(/\d{8}/)[0]
    File.delete(cache) if match.nil? || match.to_i <= cutoff
  end
end

def convert_ms_to_time_format(ms)
  Time.at(ms / 1000).utc.strftime("%H:%M:%S.#{ms % 1000}")
end

cleanup_old_cache
authenticate
playlists = get_playlists

rows = []
template = File.read(TEMPLATE)
File.delete(RESULTS) if File.exists?(RESULTS)

playlists.each do |playlist|
  playlist.tracks.each do |track|
    print track.name

    query = track.name.split('(').first.strip.split('-').first.strip
    dupes = find_dupes query

    rows << {
      query: query,
      preview_url: track.preview_url,
      playlist: playlist.name,
      track_name: track.name,
      artists: track.artists.map(&:name),
      duration: convert_ms_to_time_format(track.duration_ms),
      album: {
        name: track.album.name,
        image: track.album.images.find { |i| i['height'] == 64 }.try(:[], ['url'])
      },
      amazon_url: "https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Ddigital-music&field-keywords=#{URI.escape("#{track.name} #{track.artists.first.name}")}",
      beatport_url: "https://www.beatport.com/search?q=#{URI.escape(track.name)}",
      spotify_url: track.external_urls['spotify'],
      soundcloud_url: "https://soundcloud.com/search?q=#{URI.escape(track.name)}",
      dupes: dupes.map { |dupe|
        {
          filename: dupe.filename,
          path: dupe.path,
          duration: dupe.duration,
          name: dupe.title,
          artist: dupe.artist,
          album: dupe.album,
        }
      },
    }

    File.open(RESULTS, "w") { |f| f.write(ERB.new(template).result(binding)) }
    print " → #{dupes.size} #{'dupe'.pluralize(dupes.size)} for \"#{query}\""
    puts
  end
end
