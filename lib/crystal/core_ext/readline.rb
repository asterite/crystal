module Readline
  LOG = "#{ENV['HOME']}/.crystal-history"

  class << self
    alias :old_readline :readline
    def readline(*args)
      line = old_readline(*args)
      File.open(LOG, 'ab') {|file| file << "#{line}\n"} rescue nil
      line
    end

    def read_history
      if File.exists? LOG
        File.readlines(LOG).each do |line|
          HISTORY.push line
        end
      end
    end
  end
end
