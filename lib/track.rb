require 'mp3info'

class Track
  FILTERS = ['remix', 'explicit', 'clean', 'original mix', /\s/, /[^A-Za-z0-9]/]

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
    # Lower case
    title_part = title.downcase
    # Filter patterns and words
    FILTERS.each { |word_or_pattern| title_part = title_part.gsub(word_or_pattern, '') }
    # Take only the first five characters
    title_part = title_part[0...5]
    duration_part = (duration / 10_000.0).round
    [title_part, duration_part].join('-')
  end
end
