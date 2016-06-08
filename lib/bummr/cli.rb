TEST_COMMAND = ENV["BUMMR_TEST"] || "bundle exec rake"

module Bummr
  class CLI < Thor
    desc "check", "Run automated checks to see if bummr can be run"
    def check(fullcheck=true)
      Bummr::Check.instance.check(fullcheck)
    end

    desc "update", "Update outdated gems, run tests, bisect if tests fail"
    def update
      ask_questions

      if yes? "Are you ready to use Bummr? (y/n)"
        check
        log("Bummr update initiated #{Time.now}")
        system("bundle")

        outdated_gems = Bummr::Outdated.instance.outdated_gems

        if outdated_gems.empty?
          say "No outdated gems to update".green
        else
          Bummr::Updater.instance.update_gems(outdated_gems)

          system("git rebase -i master")
          test
        end
      else
        say "Thank you!".green
      end
    end

    desc "test", "Test for a successful build and bisect if necesssary"
    def test
      check(false)
      system "bundle"
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

      Bummr::Updater.instance.bisect
    end

    private

    def ask_questions
      say "To run Bummr, you must:"
      say "- Be in the root path of a clean git branch off of master"
      say "- Have no commits or local changes"
      say "- Have a 'log' directory, where we can place logs"
      say "- Have your build configured to fail fast (recommended)"
      say "- Have locked any Gem version that you don't wish to update in your Gemfile"
      say "- It is recommended that you lock your versions of `ruby` and `rails in your Gemfile`"
      say "Your test command is: '#{TEST_COMMAND}'"
    end

    def log(message)
      say message
      system("touch log/bummr.log && echo '#{message}' >> log/bummr.log")
    end
  end
end
