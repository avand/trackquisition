require 'yaml'
require 'args_parser'
require 'library.rb'
require 'config.rb'
require 'playlist.rb'
require 'track.rb'
require 'webpage.rb'

Config.init

args = ArgsParser.parse ARGV do
  arg :playlist, 'Spotify playlist name (disregard parent folders; collaborative playlists not supported)', alias: :p
  arg :output, 'Name of the file generated for acquisition', alias: :o, default: Config['output']
  arg :verbose, 'Show more information when running (like errors)', alias: :v, default: false
  arg :help, 'Prints these usage instructions', alias: :h
end

if args.has_param? :playlist
  playlist = Playlist.new args[:playlist]
  library = Library.new Config['tracks_dir']
  webpage = Webpage.new args[:playlist], args[:output]

  library.build display_errors: args[:verbose]

  rows = playlist.spotify_tracks.each do |spotify_track|
    signature = Track.generate_signature(spotify_track.name, spotify_track.duration_ms)
    dupes = library[signature]
    webpage.add_track(spotify_track, signature, dupes)
  end

  webpage.render
  webpage.open
else
  puts args.help
end
