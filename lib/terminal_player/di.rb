class DI < Site
  def initialize(options)
    p = !options[:url]['premium'].nil?
    super(options, p ? 'di-hi' : 'di-lo')
  end

  def get_channels
    @channels = []
    f = open('http://www.di.fm')
    page = f.read
    chan_ids = page.scan(/data-channel-id="(\d+)"/).flatten
    chans = page.scan(/data-tunein-url="http:\/\/www.di.fm\/(.*?)"/).flatten
    zipped = chan_ids.zip(chans)
    zipped.each do |z|
      @channels << {id: z[0], name: z[1]}
    end
    @channels.sort_by! {|k, _| k[:name]}
    @channels.uniq! {|k, _| k[:name]}
  end
end
