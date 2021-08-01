require 'yaml'
require 'args_parser'
require 'library.rb'
require 'config.rb'
require 'playlist.rb'
require 'track.rb'
require 'webpage.rb'

Config.init
RSpotify.authenticate Config['spotify']['client_id'], Config['spotify']['client_secret']
