require 'track.rb'
require 'utils/suppress_output.rb'

class Library
  PRINT_EVERY = 100

  attr_reader :tracks_dir, :client, :errors

  def initialize(tracks_dir)
    @tracks_dir = tracks_dir
    @errors = []
  end

  def build(display_errors: false)
    @tracks = Hash.new { |hash, key| hash[key] = [] }

    files = Dir.glob("#{@tracks_dir}/**/*.mp3")

    print 'Analyzing your library...'

    files.each_with_index do |file, i|
      begin
        suppress_output do
          track = Track.new(file)
          @tracks[track.signature] << track.attributes
        end
        print '.' if i % PRINT_EVERY == 0
      rescue => error
        print 'F'
        errors << error
      end
    end

    print "done (#{size} tracks, #{errors.length} errors)!"
    puts
    puts errors if display_errors && errors.length > 0
  end

  def size
    @tracks.values.flatten.length
  end

  def [](signature)
    @tracks[signature]
  end
end
