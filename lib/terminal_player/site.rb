require 'observer'

class Site
  include Observable

  attr_accessor :songs, :player
  attr_reader :name, :current_channel, :channels, :is_spotify, :is_di_plus

  def initialize(options, name)
    @name = name
    @songs = []
    @channels = []

    options[:cache] || options[:cache] = 512
    options[:cache_min] || options[:cache_min] = 30
    options[:url] || options[:url] = ''

    if options[:url].nil? || options[:url].empty?
      fail "no :url in the options hash sent to Site"
    end

    @is_di_plus = options[:di_plus]

    @is_spotify = !options[:url]['spotify:'].nil?
    if @is_spotify
      @current_channel = spotify_type(options[:url])
    else
      @current_channel = options[:url].split('/').last
      @current_channel = @current_channel[0..@current_channel.index('.') - 1]
    end

    if @is_spotify
      @player = SpotiphyPlayer.new(options)
    else
      @player = Mplayer.new({cache: options[:cache],
                             cache_min: options[:cache_min],
                             url: options[:url]})
    end
    PlayerMessageObserver.new(self, @player)
  end

  def play
    @player.play
  end

  def song_changed
    changed
    notify_observers(Time.now, @songs)
  end

  private

  def spotify_type(uri)
    return 'playlist' if uri[':playlist:']
    return 'album' if uri[':album:']
    return 'track' if uri[':track:']
    return uri
  end
end

class Site::Observer
  def initialize(site, player)
    @site = site
    player.add_observer(self)
  end
end

class PlayerMessageObserver < Site::Observer
  @channels = []

  def update(time, message)
    if message['ICY']
      begin
        m = message.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        song = m[/StreamTitle='(.*?)'/, 1]
      rescue => e
        song = "error: #{e}"
      end
      @site.songs << song
      @site.song_changed
    elsif message['SPOTTY']
      @site.songs << message.gsub(/SPOTTY /, '')
      @site.song_changed
    elsif message['Cache ']
      write message
    end
  end

  def write(message)
    puts "\n#{Time.now.strftime("%H:%M:%S")} [#{@site.name}] #{message}\r"
  end
end
