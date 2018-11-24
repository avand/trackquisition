# Buy Tracks 🤑 🎶

![Screenshot](./screenshot.png "Screenshot")

The basic idea behind this software library is to make it easier to purchase music. Everyone has different workflows. Buy Tracks works well if you acquire music like this:

1. You manage playlists on Spotify
2. You periodically want to buy tracks from certain playlists
3. You want to avoid buying the same track twice (maybe you share a library)
4. You want to quickly search for, add tracks to a cart, and checkout (without typing the song names a bajillion times)

Buy Tracks is a command line tool that generates an HTML file you can open on your computer and use to search for and buy tracks more easily.

I hope you like it!

# Installation

1. Clone this repo to your Mac (haven't tried on other systems)
2. Run `./install.sh` (from within the repo folder)
3. 🤞
4. Edit `config.yml` (head over to Spotify and create a Client ID)

You'll need Ruby and Homebrew installed on your machine for all this to work. The installation script will install and start ElasticSearch. Buy Tracks uses an ElasticSearch index to search for duplicate tracks.

# Usage

## Build Your Library's Index

If you're using this for the first time—or you haven't used it in a while—start by indexing your library.

``` sh
❯ bundle exec buy-tracks --build
/Users/Avand/Library/Mobile Documents/com~apple~CloudDocs/iTunes
.....................................................................................................................................
Time: 40.82213
Errors: 0
Tracks: 1293
```

## Shop for a Spotify Playlist

With your library indexed, you can now analyze one of your Spotify playlists:

``` sh
❯ bundle exec buy-tracks --playlist '2018 / 7'
..............................
```

When that process finishes, a HTML file will open up in your browser. Use that interface to link out to your favorite online stores and add tracks to your cart.
