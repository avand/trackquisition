require 'elasticsearch'
require 'mp3info'

INDEX = 'tracks'
TYPE = 'track'

class Library
  attr_reader :client, :errors

  def initialize(tunes_dir, options = {})
    @tunes_dir = tunes_dir
    @client = Elasticsearch::Client.new options
    @errors = []
  end

  def build
    client.indices.delete index: INDEX

    client.indices.create index: INDEX, body: {
      mappings: {
        track: {
          properties: {
            title: { type: 'text' },
            artist: { type: 'keyword' },
            album: { type: 'keyword' }
          }
        }
      }
    }

    client.delete_by_query index: INDEX, body: { query: { match_all: {} } }

    files = Dir.glob("#{@tunes_dir}/**/*.mp3")

    files.each_with_index do |file, i|
      begin
        mp3 = Mp3Info.open(file)

        client.index index: INDEX, type: TYPE, body: {
          title: mp3.tag.title,
          artist: mp3.tag.artist,
          album: mp3.tag.album,
          filename: File.basename(file),
          path: file,
          duration: mp3.length,
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

  def search(options = {})
    query = { query: { bool: {} } }

    if options[:title].present?
      query[:query][:bool][:must] = {
        match: {
          title: options[:title]
        }
      }
    end

    if options[:artist].present?
      query[:query][:bool][:filter] = {
        term: {
          artist: options[:artist]
        }
      }
    end

    client.search({ index: INDEX, body: query })
  end
end
