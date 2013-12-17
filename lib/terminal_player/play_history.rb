require 'logger'
require 'fileutils'

class PlayHistory
  def self.write(path, message)
    FileUtils.mkdir_p(path)
    logger = Logger.new("#{path}/play_history.log", 'daily')
    logger.formatter = proc do |severity, datetime, progname, msg|
      "#{msg}\n"
    end
    logger.info(message)
    logger.close
  end
end
