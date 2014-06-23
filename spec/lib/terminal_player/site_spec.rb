require 'spec_helper'
require 'terminal_player'

describe Site do
  it "bombs with no url" do
    options = {cache: 999, cache_min: 12, url: ''}
    expect(lambda { Site.new(options, "di") }).to raise_error RuntimeError
  end

  it "sets up properly for di.fm" do
    options = {cache: 999, cache_min: 12, url: 'http://www.di.fm/breaks.pls'}
    s = Site.new(options, 'di')
    expect(s.name).to eql 'di'
    expect(s.current_channel).to eql 'breaks'
    expect(s.player.class).to be Mplayer
    expect(s.is_mplayer).to be true
  end
end
