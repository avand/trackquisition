require 'elasticsearch'
require 'id3tag'

INDEX = 'tracks'
TYPE = 'track'

class Library
  TUNES_DIR = '/Users/Avand/Dropbox/Tunes'

  attr_reader :client, :errors

  def initialize(options = {})
    @client = Elasticsearch::Client.new options
    @errors = []
  end

  def build
    if !client.indices.exists index: INDEX
      client.indices.create index: INDEX
    end

    client.delete_by_query index: INDEX, body: { query: { match_all: {} } }

    files = Dir.glob("#{TUNES_DIR}/**/*.mp3")

    files.each_with_index do |file, i|
      begin
        tag = ID3Tag.read(File.open(file, 'rb'))

        client.index index: INDEX, type: TYPE, body: {
          title: tag.title,
          artist: tag.artist,
          album: tag.album
        }

        print '.' if i % 10 == 0
      rescue => error
        print 'F'
        errors << error
      end
    end
  end

  def size
    client.count(index: INDEX)['count']
  end
end
