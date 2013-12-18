# Terminal Player

Terminal player is a bare-bones, terminal-based player for DI.fm and somafm.com. It's a thin wrapper around `mplayer` and it outputs a single line of text: the current song. That's it. A two-line terminal is plenty of room.

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

    -p, --premium-id PREMIUM_ID      Set your DI.fm premium ID
    -c, --cache CACHE_SIZE           Set the cache size (KB)
    -m, --cache-min CACHE_MIN        Set the minimum cache threshold (percent)
    -h, --help                       Display this message
        --play-history-path PATH     Log the play history to PATH
```

Examples:
```
# DI premium member, breaks channel
$ terminal_player --premium-id abc123 di breaks

# DI public breaks channel
$ terminal_player di breaks

# Soma Secret Agent
$ terminal_player soma secretagent130

# Soma Groove Salad, log the song history to the desktop in a folder called played_songs
$ terminal_player --play-history-path ~/Desktop/played_songs soma groovesalad

# Spotify bitchin playlist
$ terminal_player spotify spotify:user:whoknows:playlist:0AykzuRPoExXhCRlazt14O
```

You can get a channel list if you use `channels` as the channel argument:
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

Channels:
```
c       - Display a channel list
```

Spotify "integration":
```
s       - Launch a browser, search google for site:spotify.com and the track/artist name
```

`mplayer` control:
```
9       - Lower volume
0       - Raise volume
<space> - Pause
```

## Play logs

They're rotated daily. They're formatted like the display is:
```
# Logfile created on 2013-12-16 22:34:19 -0500 by logger.rb/41954
22:34:19 [soma/secretagent130] Akasha - Mescalin
22:36:14 [soma/secretagent130] Sunday Combo - Ball Chair
22:39:14 [soma/secretagent130] Daniele Luppi - The Lost Island (Lp Version)
```
