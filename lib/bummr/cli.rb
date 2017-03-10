TEST_COMMAND = ENV["BUMMR_TEST"] || "bundle exec rake"
BASE_BRANCH = ENV["BASE_BRANCH"] || "master"

module Bummr
  class CLI < Thor
    include Bummr::Log

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
          puts "No outdated gems to update".color(:green)
        else
          Bummr::Updater.new(outdated_gems).update_gems

          system("git rebase -i #{BASE_BRANCH}")
          test
        end
      else
        puts "Thank you!".color(:green)
      end
    end

    desc "test", "Test for a successful build and bisect if necesssary"
    def test
      check(false)
      system "bundle"
      puts "Testing the build!".color(:green)

      if system(TEST_COMMAND) == false
        bisect
      else
        puts "Passed the build!".color(:green)
        puts "See log/bummr.log for details".color(:yellow)
        system("cat log/bummr.log")
      end
    end

    desc "bisect", "Find the bad commit, remove it, test again"
    def bisect
      check(false)

      Bummr::Bisecter.instance.bisect
    end

    private

    def ask_questions
      puts "To run Bummr, you must:"
      puts "- Be in the root path of a clean git branch off of #{BASE_BRANCH}"
      puts "- Have no commits or local changes"
      puts "- Have a 'log' directory, where we can place logs"
      puts "- Have your build configured to fail fast (recommended)"
      puts "- Have locked any Gem version that you don't wish to update in your Gemfile"
      puts "- It is recommended that you lock your versions of `ruby` and `rails in your Gemfile`"
      puts "Your test command is: '#{TEST_COMMAND}'"
    end
  end
end
