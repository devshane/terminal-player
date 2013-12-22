require 'spec_helper'
require 'terminal_player'

describe Site do
  it "bombs with no url" do
    options = {cache: 999, cache_min: 12, url: ''}
    lambda { Site.new(options, "di") }.should raise_error RuntimeError
  end

  it "sets up properly for di.fm" do
    options = {cache: 999, cache_min: 12, url: 'http://www.di.fm/breaks.pls'}
    s = Site.new(options, 'di')
    s.name.should == 'di'
    s.current_channel.should == 'breaks'
    s.player.class.should be Mplayer
    s.is_mplayer.should be true
  end

  it "should return appropriate types for spotify URIs" do
    # use di because firing up spotify without username/password bombs
    options = {cache: 999, cache_min: 12, url: 'http://www.di.fm/breaks.pls'}
    s = Site.new(options, 'di')

    output = s.send(:spotify_type, 'spotify:album:5PFwYpKSHE3Zab4YTrgyv2')
    output.should == 'album'

    output = s.send(:spotify_type, 'spotify:playlist:5PFwYpKSHE3Zab4YTrgyv2')
    output.should == 'playlist'

    output = s.send(:spotify_type, 'spotify:track:5PFwYpKSHE3Zab4YTrgyv2')
    output.should == 'track'

    output = s.send(:spotify_type, 'spotify:unknown:5PFwYpKSHE3Zab4YTrgyv2')
    output.should == 'spotify:unknown:5PFwYpKSHE3Zab4YTrgyv2'
  end
end
