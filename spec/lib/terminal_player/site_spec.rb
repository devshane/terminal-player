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
end
