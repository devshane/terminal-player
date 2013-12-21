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
          list_channels
          update(Time.now, @site.songs)
        when 'n'
          @site.player.next if @site.is_spotify
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
        sleep 0.1
      end
    end
  end

  def google(s)
    `open "https://www.google.com/search?safe=off&q=#{s}"`
  end

  def play
    keypress_handler
    @site.play
  end

  def update(time, songs)
    unless @last_log == songs.last
      @last_log = song = songs.last

      song = "#{song} #{get_di_info}" if @site.is_di_plus

      s = "#{time.strftime("%H:%M:%S")} [#{@site.name}/#{@site.current_channel}] #{song}"
      print "\n#{s}\r"
      unless @options[:play_history_path].empty?
        PlayHistory.write @options[:play_history_path], s
      end
    end
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
  end

  private

  def get_di_info
    chid = 0
    @channels ||= @site.get_channels
    @channels.each do |c|
      if c[:name] == @site.current_channel
        chid = c[:id].to_i
        break
      end
    end
    if chid > 0
      sleep 2 # HACK!
      songs = @site.get_recently_played_list(chid) if chid > 0
      s = songs.first
      song = "#{song} :: #{format_secs(s['duration'])} " \
      "+#{s['votes']['up']} -#{s['votes']['down']}"
    end
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
end
