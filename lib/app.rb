require 'yaml'
require 'args_parser'
require 'library.rb'
require 'config.rb'
require 'playlist.rb'
require 'track.rb'
require 'webpage.rb'

Config.init
RSpotify.authenticate Config['spotify']['client_id'], Config['spotify']['client_secret']

args = ArgsParser.parse ARGV do
  arg :playlist, 'Spotify playlist name (disregard parent folders; collaborative playlists not supported)', alias: :p
  arg :playlists, 'List all Spotify playlist for the configured user', alias: :l
  arg :output, 'Name of the file generated for acquisition', alias: :o, default: Config['output']
  arg :verbose, 'Show more information when running (like errors)', alias: :v, default: false
  arg :help, 'Prints these usage instructions', alias: :h
end

if args.has_option? :playlists
  Playlist.all.each do |playlist|
    puts "#{playlist.name} (#{playlist.external_urls["spotify"]})"
  end
elsif args.has_param? :playlist
  begin
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
  rescue Playlist::NotFoundError
    puts "Could not find a playlist called #{args[:playlist]}. If the playlist is or was collaborative, create a new playlist and copy the tracks."
    puts "You can also try running this command again with -l to see all the playlists options."
  end
else
  puts args.help
end
