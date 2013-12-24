require 'spotify'
require 'plaything'

class SpotiphyPlayer
  include Observable

  def initialize(options)
    @options = options

    @plaything = Plaything.new
    setup_session_callbacks

    # HACK not sure this is copacetic
    path = File.expand_path File.dirname(__FILE__)
    appkey = IO.read("#{path}/../../../spotify_appkey.key", encoding: "BINARY")
    config = Spotify::SessionConfig.new({
      api_version: Spotify::API_VERSION.to_i,
      application_key: appkey,
      cache_location: ".spotify/",
      settings_location: ".spotify/",
      tracefile: "spotify_tracefile.txt",
      user_agent: "spotify for ruby",
      callbacks: Spotify::SessionCallbacks.new($session_callbacks),
    })
    @session = create_session(config)

    login(get_env("SPOTIFY_USERNAME"), get_env("SPOTIFY_PASSWORD"))
  end

  def play
    u = @options[:url]
    if u[':track:']
      play_track_from_uri u
    elsif u[':playlist:']
      play_playlist u
    elsif u[':album:']
      play_album u
    else
      puts "unsupported URI #{u}"
    end
  end

  def next
    $end_of_track = true
  end

  def get_track(uri)
    link = Spotify.link_create_from_string(uri)
    track = Spotify.link_as_track(link)
    track
  end

  def play_track_from_uri(uri)
    track = get_track(uri)
    play_track track
  end

  def play_track(track)
    wait_for_track_to_load track
    artist = Spotify.track_artist(track, 0)
    notify "SPOTTY #{Spotify.track_name(track)} - #{Spotify.artist_name(artist)}"
    begin
      play_track_raw track
      wait_for_track_to_end
    rescue => e
      puts "play_track: error playing track: #{e}"
    end
  end

  def play_playlist(uri)
    link = Spotify.link_create_from_string(uri)
    plist = Spotify.playlist_create(@session, link)
    poll(@session) { Spotify.playlist_is_loaded(plist) }
    num_tracks = Spotify.playlist_num_tracks(plist)
# TODO this should reset channel
#    puts "\nPlaying #{Spotify.playlist_name(plist)}, #{num_tracks} tracks, " +
#         "#{Spotify.playlist_num_subscribers(plist)} subscribers"
    0.upto(num_tracks - 1) do |i|
      track = Spotify.playlist_track(plist, i)
      play_track track
    end
  end

  def play_album(uri)
    link = Spotify.link_create_from_string(uri)
    browser = Spotify.albumbrowse_create(@session, Spotify.link_as_album(link), proc { }, nil)
    poll(@session) { Spotify.albumbrowse_is_loaded(browser) }
#    album = Spotify.albumbrowse_album(browser)
    num_tracks = Spotify.albumbrowse_num_tracks(browser)
# TODO this should reset channel
#    puts "\nPlaying #{Spotify.album_name(album)} (#{Spotify.album_year(album)}), #{num_tracks} tracks"
    0.upto(num_tracks - 1) do |i|
      track = Spotify.albumbrowse_track(browser, i)
      play_track track
    end
  end

  def play_track_raw(track)
    Spotify.try(:session_player_play, @session, false)
    Spotify.try(:session_player_load, @session, track)
    Spotify.try(:session_player_play, @session, true)
  end

  def wait_for_track_to_end
    poll(@session) { $end_of_track }
    $end_of_track = false
  end

  def wait_for_track_to_load(track)
    poll(@session) { Spotify.track_is_loaded(track) }
  end

  private

  def notify(message)
    changed
    notify_observers(Time.now, message)
  end

  def login(u, p)
    Spotify.session_login(@session, u, p, false, nil)
    poll(@session) { Spotify.session_connectionstate(@session) == :logged_in }
  end

  def poll(session)
    until yield
      FFI::MemoryPointer.new(:int) do |ptr|
        Spotify.session_process_events(session, ptr)
      end
      sleep(0.1)
    end
  end

  def create_session(config)
    FFI::MemoryPointer.new(Spotify::Session) do |ptr|
      Spotify.try(:session_create, config, ptr)
      return Spotify::Session.new(ptr.read_pointer)
    end
  end

  def setup_session_callbacks
    # these must remain global. i think.
    $session_callbacks = {
      log_message: proc do |session, message|
        #$logger.info("session (log message)") { message }
      end,

      logged_in: proc do |session, error|
        #$logger.debug("session (logged in)") { Spotify::Error.explain(error) }
      end,

      logged_out: proc do |session|
        #$logger.debug("session (logged out)") { "logged out!" }
      end,

      streaming_error: proc do |session, error|
        #$logger.error("session (player)") { "streaming error %s" % Spotify::Error.explain(error) }
      end,

      start_playback: proc do |session|
        #$logger.debug("session (player)") { "start playback" }
        @plaything.play
      end,

      stop_playback: proc do |session|
        #$logger.debug("session (player)") { "stop playback" }
        @plaything.stop
      end,

      get_audio_buffer_stats: proc do |session, stats|
        stats[:samples] = @plaything.queue_size
        stats[:stutter] = @plaything.drops
        #$logger.debug("session (player)") { "queue size [#{stats[:samples]}, #{stats[:stutter]}]" }
      end,

      music_delivery: proc do |session, format, frames, num_frames|
        if num_frames == 0
          #$logger.debug("session (player)") { "music delivery audio discontuity" }
          @plaything.stop
          0
        else
          frames = FrameReader.new(format[:channels], format[:sample_type], num_frames, frames)
          consumed_frames = @plaything.stream(frames, format.to_h)
          #$logger.debug("session (player)") { "music delivery #{consumed_frames} of #{num_frames}" }
          consumed_frames
        end
      end,

      end_of_track: proc do |session|
        $end_of_track = true
        #$logger.debug("session (player)") { "end of track" }
        @plaything.stop
      end,
    }
  end

  def get_env(name)
    ENV.fetch(name) do
      raise "set the #{name} environment variable"
    end
  end
end

