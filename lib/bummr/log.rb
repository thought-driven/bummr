module Bummr
  module Log
    def log(message)
      puts message
      system("touch log/bummr.log && echo '#{message}' >> log/bummr.log")
    end
  end
end
