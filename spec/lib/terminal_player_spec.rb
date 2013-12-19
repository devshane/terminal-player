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
    tp.instance_variable_get(:@site).class.should be DI
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
    output = capture_stdout {
      lambda { TerminalPlayer.new(options) }.should raise_error SystemExit
    }
    output.should include 'ambient'
    output.should include 'breaks'
    output.should include 'vocaltrance'
  end

  it "lists soma channels" do
    options = { url: 'http://somafm.com/channels.pls' }
    output = capture_stdout {
      lambda { TerminalPlayer.new(options) }.should raise_error SystemExit
    }
    output.should include 'doomed'
    output.should include 'lush64'
    output.should include 'u80s130'
  end
end
