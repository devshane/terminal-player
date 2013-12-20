require 'spec_helper'
require 'terminal_player'

def capture_stdout(&block)
  original_stdout = $stdout
  $stdout = fake = StringIO.new
  begin
    yield
  ensure
    $stdout = original_stdout
  end
  fake.string
end

describe TerminalPlayer do
  it "sets up properly for di.fm" do
    options = { url: 'http://www.di.fm/' }
    tp = TerminalPlayer.new(options)
    s = tp.instance_variable_get(:@site)
    s.class.should be DI
    s.instance_variable_get(:@name).should == 'di-lo'
  end

  it "sets up properly for somafm.com" do
    options = { url: 'http://somafm.com/' }
    tp = TerminalPlayer.new(options)
    tp.instance_variable_get(:@site).class.should be Soma
  end

  it "sets up properly for spotify" do
    options = { url: 'spotify:blah:blah' }
    tp = TerminalPlayer.new(options)
    tp.instance_variable_get(:@site).class.should be Spotiphy
  end

  it "bombs with a bad site" do
    options = { url: 'unknown' }
    lambda { TerminalPlayer.new(options) }.should raise_error
  end

  it "lists di channels" do
    options = { url: 'http://www.di.fm/channels.pls' }
    output = capture_stdout do
      lambda { TerminalPlayer.new(options) }.should raise_error SystemExit
    end
    output.should include 'ambient'
    output.should include 'breaks'
    output.should include 'vocaltrance'
  end

  it "lists soma channels" do
    options = { url: 'http://somafm.com/channels.pls' }
    output = capture_stdout do
      lambda { TerminalPlayer.new(options) }.should raise_error SystemExit
    end
    output.should include 'doomed'
    output.should include 'lush64'
    output.should include 'u80s130'
  end

  it "displays songs" do
    options = {
      url: 'http://www.di.fm/premium_high/breaks.pls?abc123',
      play_history_path: ''
    }
    tp = TerminalPlayer.new(options)
    tp.instance_variable_get(:@site).class.should be DI
    tp.instance_variable_get(:@site).instance_variable_get(:@name).should == 'di-hi'
    tp.instance_variable_get(:@site).instance_variable_get(:@current_channel).should == 'breaks'

    t = Time.now
    output = capture_stdout do
      songs = ['one', 'two', 'three']
      tp.update(t, songs)
    end
    output.should include t.strftime("%H:%M:%S")
    output.should include '[di-hi/breaks]'
    output.should include 'three'
  end

  it "cleans song titles" do
    options = { url: 'http://somafm.com/' }
    tp = TerminalPlayer.new(options)
    ab = 'ali baba and the forty theieves'
    output = tp.send(:cleanup, ab)
    output.should == ab.gsub(/ /, '+')
  end

  it "removes common crud in song titles" do
    options = { url: 'http://somafm.com/' }
    tp = TerminalPlayer.new(options)
    # Feat.
    ab = 'ali baba Feat. the forty theieves'
    output = tp.send(:cleanup, ab)
    output.should == 'ali+baba+the+forty+theieves'

    # Many, but not all, non-word characters
    ab = "?ali \tbaba , th\ne .forty thei^eves&*"
    output = tp.send(:cleanup, ab)
    output.should == 'ali+baba+the+.forty+theieves'
  end

  it "removes stuff in parenthesis from song titles" do
    options = { url: 'http://somafm.com/' }
    tp = TerminalPlayer.new(options)

    # anything in parenthesis
    ab = 'ali baba (original mix) - forty thieves'
    output = tp.send(:cleanup, ab)
    output.should == 'ali+baba+forty+thieves'

    # ... even partially
    ab = 'ali baba (ori'
    output = tp.send(:cleanup, ab)
    output.should == 'ali+baba'
  end
end
