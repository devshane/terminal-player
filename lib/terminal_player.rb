require 'observer'

require 'terminal_player/site'
require 'terminal_player/mplayer'
require 'terminal_player/play_history'
require 'terminal_player/di/di'
require 'terminal_player/soma/soma'

class TerminalPlayer
  def initialize(options)
    @options = options
    if @options[:url]['di.fm']
      @site = DI.new(@options)
    elsif @options[:url]['somafm.com']
      @site = Soma.new(@options)
    else
      fail "no url"
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
        when 's'
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
    `open "https://www.google.com/search?safe=off&q=site:spotify.com+#{s}"`
  end

  def play
    keypress_handler
    @site.play
  end

  def update(time, songs)
    s = "#{time.strftime("%H:%M:%S")} [#{@site.name}/#{@site.current_channel}] #{songs.last}"
    print "\n#{s}\r"
    unless @options[:play_history_path].empty?
      PlayHistory.write @options[:play_history_path], s
    end
  end
end
