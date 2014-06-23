# Terminal Player

Terminal player is a bare-bones, terminal-based player for DI.fm and somafm.com. It's a thin wrapper 
around `mplayer` and it outputs a single line of text for each song without using Curses. That's it. 
A two-line terminal is plenty of room:

```
16:28:34 [di/lounge] The Sura Quintet - Kept In Perspective
16:29:46 [di/lounge] Michel Petit - Voyage A Tipaza
```

Pull requests are encouraged.

## Installation
```
$ gem install terminal_player
```

Or from source:
```
$ git clone https://github.com/devshane/terminal-player.git
$ cd terminal-player
$ gem build ./terminal_player.gemspec
$ gem install ./terminal_player-0.0.4.gem
```

## Usage
```
Usage: terminal_player.rb [options] site channel

The `site` parameter can be di or soma.

When `site` is di or soma, the channel parameter should be a valid channel.
DI premium channels require an environment variable: DI_FM_PREMIUM_ID.

    -c, --cache CACHE_SIZE           Set the cache size (KB)
    -m, --cache-min CACHE_MIN        Set the minimum cache threshold (percent)
    -h, --help                       Display this message
        --play-history-path PATH     Log the play history to PATH
```

Examples:
```
# DI premium member, breaks channel
$ set -x DI_FM_PREMIUM_ID abc123; terminal_player di breaks

# DI public breaks channel
$ terminal_player di breaks

# Soma Secret Agent
$ terminal_player soma secretagent130

# Soma Groove Salad, log the song history to the desktop in a folder called played_songs
$ terminal_player --play-history-path ~/Desktop/played_songs soma groovesalad
```

## Channel lists

For DI and Soma, terminal player can dump a list of channels and then exit if you use `channels` as the channel argument:
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

$
```

## Keybinds

```
c       - Display a channel list
r       - Refresh display
S       - Launch a Google search for the track/artist name
9       - Lower volume
0       - Raise volume
<space> - Pause
```

## Play logs

They're rotated daily. They're formatted like the display is:
```
22:34:19 [soma/secretagent130] Akasha - Mescalin
22:36:14 [soma/secretagent130] Sunday Combo - Ball Chair
22:39:14 [soma/secretagent130] Daniele Luppi - The Lost Island (Lp Version)
```
