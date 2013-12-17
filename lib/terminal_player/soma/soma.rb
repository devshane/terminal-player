class Soma < Site
  def initialize(options)
    super(options, "soma")
  end

  def get_channels
    @channels = []
    f = open('http://somafm.com/listen')
    page = f.read
    chans = page.scan(/\/play\/(.*?)"/).flatten
    chans.each do |c|
      next if c['fw/']
      @channels << {id: 0, name: c}
    end
    @channels.sort_by! {|k, _| k[:name]}
    @channels.uniq! {|k, _| k[:name]}
  end
end
