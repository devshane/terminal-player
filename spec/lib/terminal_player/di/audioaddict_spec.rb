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
    expect(songs.length).to be > 0
    s = songs[0]
    expect(s['channel_id']).to eql 15

    expect(s['duration']).not_to be nil
    expect(s).to respond_to(:length)
    expect(s['started']).not_to be nil
    expect(s['title']).not_to be nil
    expect(s['track']).not_to be nil
    expect(s['votes']).not_to be nil
  end
end
