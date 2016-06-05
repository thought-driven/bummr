require 'thor'
require 'open3'
require 'colorize'

TEST_COMMAND = ENV["BUMMR_TEST"] || "bundle exec rake"

module Bummr
  class CLI < Thor
    desc "check", "Run automated checks to see if bummr can be run"
    def check(fullcheck=true)
      errors = []

      if `git rev-parse --abbrev-ref HEAD` == "master\n"
        message = "Bummr is not meant to be run on master"
        say message.red
        say "Please checkout a branch with 'git checkout -b update-gems'"
        errors.push message
      end

      unless File.directory? "log"
        message = "There is no log directory or you are not in the root"
        say message.red
        errors.push message
      end

      status = `git status`

      if status.index 'are currently'
        message = ""

        if status.index 'rebasing'
          message += "You are already rebasing. "
        elsif status.index 'bisecting'
          message += "You are already bisecting. "
        end

        message += "Make sure `git status` is clean"
        say message.red
        errors.push message
      end

      if fullcheck == true
        unless `git diff master`.empty?
          message = "Please make sure that `git diff master` returns empty"
          say message.red
          errors.push message
        end
      end

      if errors.any?
        exit 0
      else
        puts "Ready to run bummr.".green

      end
    end

    desc "update", "Update outdated gems, run tests, bisect if tests fail"
    def update
      say "To run Bummr, you must:"
      say "- Be in the root path of a clean git branch off of master"
      say "- Have no commits or local changes"
      say "- Have a 'log' directory, where we can place logs"
      say "- Have your build configured to fail fast (recommended)"
      say "- Have locked any Gem version that you don't wish to update in your Gemfile"
      say "- It is recommended that you lock your versions of `ruby` and `rails in your Gemfile`"
      say "Your test command is: '#{TEST_COMMAND}'"

      if yes? "Are you ready to use Bummr? (y/n)"
        check
        log("Bummr update initiated #{Time.now}")
        `bundle`

        outdated_gems = Bummr::Outdated.instance.outdated_gems

        if outdated_gems.empty?
          say "No outdated gems to update".green
        else
          say "Updating outdated gems".green

          outdated_gems.each_with_index do |gem, index|
            say "Updating #{gem[:name]}: #{index+1} of #{outdated_gems.count}"

            system("bundle update --source #{gem[:name]}")
            updated_version = `bundle list | grep " #{gem[:name]} "`.split('(')[1].split(')')[0]
            message = "Update #{gem[:name]} from #{gem[:installed]} to #{updated_version}"

            if gem[:newest] != updated_version
              log("#{gem[:name]} not updated from #{gem[:installed]} to latest: #{gem[:newest]}")
            end

            unless gem[:installed] == updated_version
              say message.green
              system("git commit -am '#{message}'")
            else
              log("#{gem[:name]} not updated")
            end
          end

          say "Choose which gems to update"
          system("git rebase -i master")

          log "Running Update + #{Time.now}"

          test
        end
      else
        say "Thank you!".green
      end
    end

    desc "test", "Test for a successful build and bisect if necesssary"
    def test
      check(false)
      `bundle`
      say "Testing the build!".green

      if system(TEST_COMMAND) == false
        bisect
      else
        say "Passed the build!".green
        say "See log/bummr.log for details".yellow
        system("cat log/bummr.log")
      end
    end

    desc "bisect", "Find the bad commit, remove it, test again"
    def bisect
      check(false)
      say "Bad commits found! Bisecting...".red

      system("git bisect start head master")

      Open3.popen2e("git bisect run #{TEST_COMMAND}") do |std_in, std_out_err|
        while line = std_out_err.gets
          puts line

          sha_regex = Regexp::new("(.*) is the first bad commit\n").match(line)
          unless sha_regex.nil?
            sha = sha_regex[1]
          end

          if line == "bisect run success\n"
            remove_commit(sha)
          end
        end
      end
    end

    private

    def log(message)
      say message
      system("touch log/bummr.log && echo '#{message}' >> log/bummr.log")
    end

    def remove_commit(sha)
      commit_message = `git log --pretty=format:'%s' -n 1 #{sha}`
      message = "Could not apply: #{commit_message}, #{sha}"

      say message.red
      log message

      say "Resetting..."
      system("git bisect reset")

      say "Removing commit..."
      if system("git rebase -X ours --onto #{sha}^ #{sha}")
        say "Successfully removed bad commit...".green
        say "Re-testing build...".green
        test
      else
        say message.red
        say "Could not automatically remove this commit!".red
        say "Please resolve conflicts, then 'git rebase --continue'."
        say "Run 'bummr test' again once the rebase is complete"
      end
    end
  end
end
