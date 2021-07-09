require 'mp3info'

class Track
  BAD_WORDS = ['remix', 'explicit', 'clean', 'original mix']

  def initialize(file)
    @file = file
    @mp3 = Mp3Info.open(file)
  end

  def attributes
    {
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      filename: File.basename(@file),
      path: @file,
    }
  end

  def title
    @title ||= @mp3.tag.title
  end

  def duration
    @duration = (@mp3.length * 1000).to_i
  end

  def artist
    @artist ||= @mp3.tag.artist
  end

  def album
    @album ||= @mp3.tag.album
  end

  def signature
    self.class.generate_signature(title, duration)
  end

  def self.generate_signature(title, duration)
    mod_title = title.downcase[0...5]
    BAD_WORDS.each { |bad_word| mod_title = mod_title.gsub(bad_word, '') }
    mod_title = mod_title.gsub(/[^A-Za-z0-9]/, '')
    mod_duration = duration / 10_000
    [mod_title, mod_duration].join('-')
  end
end
