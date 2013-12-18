class Mplayer
  include Observable

  def initialize(options)
    @options = options
    # assumes options has :cache, :cache_min, :url
  end

  def play
    return if @options[:stub] # HACK

    @player_thread = Thread.new do
      player = "mplayer -quiet -cache #{@options[:cache]} " \
               "-cache-min #{@options[:cache_min]} " \
               "-playlist \"#{@options[:url]}\" 2>&1"
      notify "starting player (cache #{@options[:cache]}, min #{@options[:cache_min]})..."
      @player_pipe = IO.popen(player, "r+")
      loop do
        line = @player_pipe.readline.chomp
        if line['Starting playback']
          notify line
        elsif line['ICY']
          notify line
        elsif line['Cache empty']
          notify line
        elsif line['Cache fill']
          notify "filling cache..."
        end
      end
      @player_pipe.close
    end
    @player_thread.join
  end

  def write(char)
    @player_pipe.write(char)
  end

  def notify(message)
    changed
    notify_observers(Time.now, message)
  end
end
