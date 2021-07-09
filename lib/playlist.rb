require 'rspotify'
require 'config.rb'

class Playlist
  attr_reader :spotify_playlist

  class NotFoundError < StandardError
  end

  def initialize(name)
    print "Loading playlist, #{name}..."
    @spotify_playlist = self.class.find(name)
    puts 'done!'
  end

  def spotify_tracks
    @spotify_playlist.tracks
  end

  def self.find(name)
    playlist = all.find { |playlist| playlist.name == name }
    raise NotFoundError if playlist.nil?
    return playlist
  end

  def self.all
    user = RSpotify::User.find(Config['spotify']['username'])

    limit, offset = 50, 0
    all_playlists = []

    loop do
      playlists = user.playlists(limit: limit, offset: offset)
      all_playlists += playlists
      break if playlists.size < limit
      offset += limit
    end

    return all_playlists.sort { |a, b| a.name <=> b.name }
  end
end
