require 'sqlite3'
require 'mp3info'
require 'i18n'

DATABASE = './db/development.db'
INDEX = 'tracks'
TYPE = 'track'

class Library
  attr_reader :tunes_dir, :client, :errors

  def initialize(tunes_dir, options = {})
    @tunes_dir = tunes_dir
    @db = SQLite3::Database.new File.expand_path(DATABASE)
    @db.results_as_hash = true
    @errors = []
  end

  def build
    @db.execute 'drop table if exists tracks;'

    @db.execute <<-SQL
      create table tracks (
        signature varchar(255),
        title varchar(255),
        artist varchar(255),
        album varchar(255),
        duration int,
        filename varchar(255),
        path varchar(244)
      );
    SQL

    files = Dir.glob("#{@tunes_dir}/**/*.mp3")

    files.each_with_index do |file, i|
      begin
        track_attributes = create_track_attributes(file)
        @db.execute "insert into tracks values (#{track_attributes.keys.map { '?' }.join(', ')})", track_attributes.values
        print '.' if i % 10 == 0
      rescue => error
        print 'F'
        raise error
        errors << error
      end
    end
  end

  def create_track_attributes(file)
    mp3 = Mp3Info.open(file)

    title = mp3.tag.title
    duration = (mp3.length * 1000).to_i

    {
      signature: generate_signature(title, duration),
      title: title,
      artist: mp3.tag.artist,
      album: mp3.tag.album,
      duration: duration,
      filename: File.basename(file),
      path: file,
    }
  end

  def generate_signature(title, duration_ms)
    bad_words = ['remix', 'explicit', 'clean', 'original mix']
    mod_title = I18n.transliterate(title).downcase[0...5]
    bad_words.each { |bad_word| mod_title = mod_title.gsub(bad_word, '') }
    mod_title = mod_title.gsub(/[^A-Za-z0-9]/, '')
    mod_duration = duration_ms / 1000
    [mod_title, mod_duration].join('-')
  end

  def size
    @db.execute('select count(*) from tracks;').first.first
  end

  def search(title, duration)
    signature = generate_signature(title, duration)

    JSON.parse(
      @db.execute('select * from tracks where signature = ?', signature).to_json,
      symbolize_names: true,
    )
  end
end
