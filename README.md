# Terminal Player

Terminal player is a bare-bones, terminal-based player for DI.fm, somafm.com, and Spotify. It's a thin wrapper around `mplayer` and `libspotify` and it outputs a single line of text: the current song. That's it. A two-line terminal is plenty of room.

Pull requests are encouraged.

## Spotify Integration

To use Spotify, you must have an account. Set these environment variables to your Spotify deets. In fish:
```
set -x SPOTIFY_USERNAME yourusername
set -x SPOTIFY_PASSWORD yourpassword
```

You can search Spotify or Google for the currently playing track by pressing `s`. See the usage and keybind sections for more.

## Installation
```
$ git clone https://github.com/devshane/terminal-player.git
$ cd terminal-player
$ gem build ./terminal_player.gemspec
$ gem install ./terminal-player-0.0.1.gem
```

## Usage
```
Usage: terminal_player.rb [options] site channel

The `site` parameter can be one of 'di', 'soma', or 'spotify'.

When using di or soma, the channel parameter should be a valid channel.
When using spotify, the channel parameter should be a Spotify URI.

    -s, --spotify-search             Enable spotify URI searches
    -p, --premium-id PREMIUM_ID      Set your DI.fm premium ID
    -c, --cache CACHE_SIZE           Set the cache size (KB)
    -m, --cache-min CACHE_MIN        Set the minimum cache threshold (percent)
    -h, --help                       Display this message
        --play-history-path PATH     Log the play history to PATH
```

Enabling `-s` or `--spotify-search` requires that you have the Spotify client installed. The option
just means terminal-player will try to `open` Spotify URIs. This probably only works on OS X.

Examples:
```
# DI premium member, breaks channel
$ terminal_player --premium-id abc123 di breaks

# DI public breaks channel
$ terminal_player di breaks

# Soma Secret Agent, enable spotify URI searches
$ terminal_player -s soma secretagent130

# Soma Groove Salad, log the song history to the desktop in a folder called played_songs
$ terminal_player --play-history-path ~/Desktop/played_songs soma groovesalad

# Spotify bitchin playlist
$ terminal_player spotify spotify:user:whoknows:playlist:0AykzuRPoExXhCRlazt14O

# Spotify track
$ terminal_player spotify spotify:track:2CTXWl2vo9oLXZaaBhpw2p
```

You can get a channel list for DI and Soma if you use `channels` as the channel argument:
```
$ terminal_player di channels

ambient             drumandbass         minimal
bigroomhouse        dubstep             moombahton
breaks              eclectronica        oldschoolacid
chillhop            electro             progressive
chillout            electronicpioneers  progressivepsy
chilloutdreams      epictrance          psychill
chillstep           eurodance           russianclubhits
chiptunes           funkyhouse          sankeys
classiceurodance    futuresynthpop      scousehouse
classiceurodisco    gabber              soulfulhouse
classictechno       glitchhop           spacemusic
classictrance       goapsy              techhouse
classicvocaltrance  handsup             techno
club                hardcore            trance
clubdubstep         harddance           trap
cosmicdowntempo     hardstyle           tribalhouse
darkdnb             hardtechno          ukgarage
deephouse           house               umfradio
deepnudisco         latinhouse          vocalchillout
deeptech            liquiddnb           vocallounge
discohouse          liquiddubstep       vocaltrance
djmixes             lounge
downtempolounge     mainstage
```

## Keybinds

```
c       - Display a channel list
n       - Change to next track (Spotify mode)
s       - Launch the Spotify player for the track/artist name
S       - Launch a Google search for the track/artist name
9       - Lower volume (not in Spotify mode)
0       - Raise volume (not in Spotify mode)
<space> - Pause (not in Spotify mode)
```

If you didn't specify `--spotify-search` on the command line, `s` will fall back to a Google search.

## Play logs

They're rotated daily. They're formatted like the display is:
```
# Logfile created on 2013-12-16 22:34:19 -0500 by logger.rb/41954
22:34:19 [soma/secretagent130] Akasha - Mescalin
22:36:14 [soma/secretagent130] Sunday Combo - Ball Chair
22:39:14 [soma/secretagent130] Daniele Luppi - The Lost Island (Lp Version)
```
