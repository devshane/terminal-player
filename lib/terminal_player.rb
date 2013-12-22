require 'observer'
require 'open-uri'

require 'terminal_player/site'
require 'terminal_player/mplayer'
require 'terminal_player/play_history'
require 'terminal_player/di'
require 'terminal_player/soma'
require 'terminal_player/spotiphy'

class TerminalPlayer
  def initialize(options)
    @last_log = ''
    @last_di_fetch = 0
    @recent_songs = []
    @stop_updating = false

    @options = options
    if @options[:url]['di.fm']
      @site = DI.new(@options)
    elsif @options[:url]['somafm.com']
      @site = Soma.new(@options)
    elsif @options[:url][':']
      @site = Spotiphy.new(@options)
    else
      fail "no url"
    end

    if @options[:url]['channels.pls']
      list_channels
      puts "\n\n"
      exit
    end

    @site.add_observer(self)
  end

  def keypress_handler
    Thread.new do
      loop do
        begin
          state = `stty -g`
          `stty raw -echo -icanon isig`
          str = STDIN.getc
        ensure
          `stty #{state}`
        end

        ch = str.chr
        case ch
        when 'c'
          @stop_updating = true
          list_channels
          @stop_updating = false
          update(Time.now, @site.songs, true, true) unless @site.is_di_plus
        when 'n'
          @site.player.next if @site.is_spotify
        when 'r'
          update(Time.now, @site.songs, true, true)
        when 's'
          if @options[:spotify_search]
            s = cleanup(@site.songs.last)
            `open "spotify:search:#{s}"`
          end
        when 'S'
          google @site.songs.last
        when '9', '0' # volume
          @site.player.write ch
        when ' ' # pause/resume
          @site.player.write ch
        end
        sleep 0.2
      end
    end
  end

  def refresh_display
    Thread.new do
      loop do
        unless @site.songs.nil?
          update(Time.now, @site.songs, true, true)
        end
        sleep 1
      end
    end
  end

  def google(s)
    `open "https://www.google.com/search?safe=off&q=#{s}"`
  end

  def play
    refresh_display if @site.is_di_plus
    keypress_handler
    @site.play
  end

  def update(time, songs, force=false, is_refresh=false)
    return if @stop_updating
    @stop_updating = true
    begin
      if @last_log != songs.last || force
        unless songs.last.nil?
          @last_log = song = songs.last
          cols = `tput cols`.to_i
          preamble = "[#{@site.name}/#{@site.current_channel}]"
          extras = @site.is_di_plus ? get_di_info : time.strftime('%H:%M:%S')
          while (1 + preamble.length + extras.length + song.length) > cols
            song = song[0..-2]
          end
          spaces = ' ' * (cols - song.length - preamble.length - extras.length - 1)
          song = "#{song}#{spaces}#{extras}"
          #print "#{is_refresh ? '' : "\n"}#{preamble} #{song}\r"
          print "\n" unless is_refresh
          print "#{preamble} #{song}\r"
          unless force || @options[:play_history_path].empty?
            PlayHistory.write @options[:play_history_path],
                              "#{time.strftime("%H:%M:%S")} #{preamble} #{songs.last}"
          end
        end
      end
    rescue => e
      write "update error: #{e}"
    end
    @stop_updating = false
  end

  def list_channels
    puts "\n\n"
    channels = @site.get_channels
    chans = channels.map { |c| c[:name] }.join("\n")
    if `which column`.empty?
      puts chans
    else
      puts `echo "#{chans}" | column`
    end
    puts "\n"
  end

  private

  def get_di_info
    chid = 0
    info = ''

    @channels ||= @site.get_channels
    @channels.each do |c|
      if c[:name] == @site.current_channel
        chid = c[:id].to_i
        break
      end
    end
    if chid > 0
      retries = 0
      status = ""
      if Time.now.to_i - @last_di_fetch > 60
        @last_di_fetch = Time.now.to_i
        @recent_songs = @site.get_recently_played_list(chid) if chid > 0
        status = "[pl] "
      end
      loop do
        s = @recent_songs.first
        next if s.nil?
        break if retries > 4
        if s['track'][@site.songs.last]
          info = " #{status}" \
            "#{format_secs(Time.now.to_i - s['started'].to_i)} > " \
            "#{format_secs(s['duration'])} : " \
            "+#{"%-2d" % s['votes']['up']} -#{"%-2d" % s['votes']['down']}"
          break
        else
          if retries >= 4
            write "giving up: can't get audioaddict info #{retries + 1}x"
            break
          end
          sleep retries + 1
          @recent_songs = @site.get_recently_played_list(chid)
        end
        retries += 1
      end
    end
    info
  end

  def format_secs(seconds)
    secs = seconds.abs
    hours = 0
    if secs > 3600
      hours = secs / 3600
      secs -= 3600 * hours
    end
    mins = secs / 60
    secs = secs % 60
    h = hours > 0 ? "#{"%d" % hours}:" : ""
    "#{h}#{"%02d" % mins}:#{"%02d" % secs}"
  end

  def cleanup(song)
    s = song.gsub(/[Ff]eat\./, '')
    s.gsub!(/\(.*?\)/, '')
    s.gsub!(/\(.*/, '')
    s.gsub!(/-/, ' ')
    s.gsub!(/[^A-Za-z \.]/, '')

    s.strip!

    s.gsub!(/ /, '+')
    s.gsub!(/\++/, '+')
    s
  end

  def write(message)
    print "\n<terminal_player-debug> #{message}\r\n"
  end
end
