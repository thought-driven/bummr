module Bummr
  class Check
    include Singleton

    def check(fullcheck=true)
      @errors = []

      check_master
      check_log
      check_status

      if fullcheck == true
        check_diff
      end

      if @errors.any?
        unless yes? "Bummr found errors! Do you want to continue anyway?".color(:red)
          exit 0
        end
      else
        puts "Ready to run bummr.".color(:green)
      end
    end

    private

    def check_master
      if `git rev-parse --abbrev-ref HEAD` == "master\n"
        message = "Bummr is not meant to be run on master"
        puts message.color(:red)
        puts "Please checkout a branch with 'git checkout -b update-gems'"
        @errors.push message
      end
    end

    def check_log
      unless File.directory? "log"
        message = "There is no log directory or you are not in the root"
        puts message.color(:red)
        @errors.push message
      end
    end

    def check_status
      status = `git status`

      if status.index 'are currently'
        message = ""

        if status.index 'rebasing'
          message += "You are already rebasing. "
        elsif status.index 'bisecting'
          message += "You are already bisecting. "
        end

        message += "Make sure `git status` is clean"
        puts message.color(:red)
        @errors.push message
      end
    end

    def check_diff
      unless `git diff master`.empty?
        message = "Please make sure that `git diff master` returns empty"
        puts message.color(:red)
        @errors.push message
      end
    end
  end
end
