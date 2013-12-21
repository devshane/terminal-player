require 'spec_helper'
require 'terminal_player/di'

describe AudioAddict do
  class DummyClass
  end

  before(:each) do
    @dummy = DummyClass.new
    @dummy.extend(AudioAddict)
  end

  it "returns a good song list" do
    songs = @dummy.get_recently_played_list(15) # 15 is breaks
    songs.length.should be > 0
    s = songs[0]
    s.should.respond_to? :channel_id
    s['channel_id'].should be 15

    s.should.respond_to? :duration
    s.should.respond_to? :length
    s.should.respond_to? :started
    s.should.respond_to? :title
    s.should.respond_to? :track
    s.should.respond_to? :votes
  end
end
