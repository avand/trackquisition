require 'erb'

class Webpage
  TEMPLATE = 'template.html.erb'

  def initialize(playlist, path)
    @rows = []
    @path = path
    @playlist = playlist

    File.delete(path) if File.exists?(path)
  end

  def add_track(spotify_track, signature, similar_tracks)
    @rows << {
      signature: signature,
      preview_url: spotify_track.preview_url,
      track_name: spotify_track.name,
      artists: spotify_track.artists.map(&:name),
      duration: convert_ms_to_time_format(spotify_track.duration_ms),
      album: {
        name: spotify_track.album.name,
        image: spotify_track.album.images.find { |i| i['height'] == 64 }['url']
      },
      amazon_url: amazon_url(spotify_track.name, spotify_track.artists.first.name),
      beatport_url: beatport_url(spotify_track.name),
      spotify_url: spotify_track.uri,
      soundcloud_url: soundcloud_url(spotify_track.name),
      similar_tracks: similar_tracks,
    }
  end

  def render
    File.open(@path, 'w') do |file|
      file.write(ERB.new(File.read(TEMPLATE)).result(binding))
    end
  end

  def open
    `open #{@path}`
  end

  def convert_ms_to_time_format(ms)
    Time.at(ms / 1000).utc.strftime("%H:%M:%S")
  end

  def amazon_url(track_name, artist_name)
    "https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Ddigital-music&field-keywords=#{URI.encode_www_form_component("#{track_name} #{artist_name}")}"
  end

  def beatport_url(track_name)
    "https://www.beatport.com/search?q=#{URI.encode_www_form_component(track_name)}"
  end

  def soundcloud_url(track_name)
    "https://soundcloud.com/search?q=#{URI.encode_www_form_component(track_name)}"
  end
end
