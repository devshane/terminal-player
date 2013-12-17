class Site
  include Observable

  attr_accessor :songs, :player

  attr_reader :name, :current_channel

  def initialize(options, name)
    @name = name
    @songs = []

    options[:cache] || options[:cache] = 512
    options[:cache_min] || options[:cache_min] = 30
    options[:url] || options[:url] = ''

    if options[:url].nil? || options[:url].empty?
      fail "no :url in the options hash sent to Site"
    end

    @current_channel = options[:url].split('/').last
    @current_channel = @current_channel[0..@current_channel.index('.') - 1]

    @player = Mplayer.new({cache: options[:cache],
                           cache_min: options[:cache_min],
                           url: options[:url]})
    PlayerMessageObserver.new(self, @player)
  end

  def play
    @player.play
  end

  def song_changed
    changed
    notify_observers(Time.now, @songs)
  end
end

class Site::Observer
  def initialize(site, player)
    @site = site
    player.add_observer(self)
  end
end

class PlayerMessageObserver < Site::Observer
  def update(time, message)
    if message['ICY']
      @site.songs << message[/StreamTitle='(.*?)'/, 1]
      @site.song_changed
    elsif message['Cache ']
      write message
    end
  end

  def write(message)
    puts "#{time.strftime("%H:%M:%S")} [#{@site.name}] #{message}"
  end
end
