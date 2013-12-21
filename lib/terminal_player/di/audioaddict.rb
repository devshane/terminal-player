require 'json'

module AudioAddict
  def get_recently_played_list(channel_id)
    rp = []

    url = "http://api.audioaddict.com/v1/di/track_history/channel/" \
          "#{channel_id}.jsonp?callback=_AudioAddict_TrackHistory_Channel"

    f = open(url)
    page = f.read
    data = JSON.parse(page[page.index("(") + 1..-3])

    data.each { |d| rp << d if d['title'] }
    rp
  end
end
