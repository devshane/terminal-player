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
    expect(s.class).to be DI
    expect(s.instance_variable_get(:@name)).to eql 'di-lo'
  end

  it "sets up properly for somafm.com" do
    options = { url: 'http://somafm.com/' }
    tp = TerminalPlayer.new(options)
    expect(tp.instance_variable_get(:@site).class).to be Soma
  end

  it "bombs with a bad site" do
    options = { url: 'unknown' }
    expect(lambda { TerminalPlayer.new(options) }).to raise_error
  end

  it "lists di channels" do
    options = { url: 'http://www.di.fm/channels.pls' }
    output = capture_stdout do
      expect(lambda { TerminalPlayer.new(options) }).to raise_error SystemExit
    end
    expect(output).to include 'ambient'
    expect(output).to include 'breaks'
    expect(output).to include 'vocaltrance'
  end

  it "lists soma channels" do
    options = { url: 'http://somafm.com/channels.pls' }
    output = capture_stdout do
      expect(lambda { TerminalPlayer.new(options) }).to raise_error SystemExit
    end
    expect(output).to include 'doomed'
    expect(output).to include 'lush64'
    expect(output).to include 'u80s130'
  end

  it "displays songs" do
    options = {
      url: 'http://www.di.fm/premium_high/breaks.pls?abc123',
      play_history_path: ''
    }
    tp = TerminalPlayer.new(options)
    expect(tp.instance_variable_get(:@site).class).to be DI
    expect(tp.instance_variable_get(:@site).instance_variable_get(:@name)).to eql 'di-hi'
    expect(tp.instance_variable_get(:@site).instance_variable_get(:@current_channel)).to eql 'breaks'

    t = Time.now
    output = capture_stdout do
      songs = ['one', 'two', 'three']
      tp.update(t, songs)
    end
    expect(output).to include t.strftime("%H:%M:%S")
    expect(output).to include '[di-hi/breaks]'
    expect(output).to include 'three'
  end

  it "doesn't display duplicate songs" do
    options = {
      url: 'http://www.di.fm/premium_high/breaks.pls?abc123',
      play_history_path: ''
    }
    tp = TerminalPlayer.new(options)
    t = Time.now
    songs = ['one', 'two', 'three']
    output = capture_stdout do
      tp.update(t, songs)
    end
    expect(output.scan(/three/).length).to eql 1

    # add a dupe
    songs << 'three'
    output += capture_stdout do
      tp.update(t, songs)
    end
    expect(output.scan(/three/).length).to eql 1
  end

  it "cleans song titles" do
    options = { url: 'http://somafm.com/' }
    tp = TerminalPlayer.new(options)
    ab = 'ali baba and the forty theieves'
    output = tp.send(:cleanup, ab)
    expect(output).to eql ab.gsub(/ /, '+')
  end

  it "removes common crud in song titles" do
    options = { url: 'http://somafm.com/' }
    tp = TerminalPlayer.new(options)
    # Feat.
    ab = 'ali baba Feat. the forty theieves'
    output = tp.send(:cleanup, ab)
    expect(output).to eql 'ali+baba+the+forty+theieves'

    # Many, but not all, non-word characters
    ab = "?ali \tbaba , th\ne .forty thei^eves&*"
    output = tp.send(:cleanup, ab)
    expect(output).to eql 'ali+baba+the+.forty+theieves'
  end

  it "removes stuff in parenthesis from song titles" do
    options = { url: 'http://somafm.com/' }
    tp = TerminalPlayer.new(options)

    # anything in parenthesis
    ab = 'ali baba (original mix) - forty thieves'
    output = tp.send(:cleanup, ab)
    expect(output).to eql 'ali+baba+forty+thieves'

    # ... even partially
    ab = 'ali baba (ori'
    output = tp.send(:cleanup, ab)
    expect(output).to eql 'ali+baba'
  end
end
