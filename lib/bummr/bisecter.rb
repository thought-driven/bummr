module Bummr
  class Updater
    include Singleton

    def bisect
      say "Bad commits found! Bisecting...".red

      system("bundle")
      system("git bisect start head master")

      Open3.popen2e("git bisect run #{TEST_COMMAND}") do |_std_in, std_out_err|
        line = std_out_err.gets

        while line
          puts line

          sha_regex = Regexp::new("(.*) is the first bad commit\n").match(line)
          unless sha_regex.nil?
            sha = sha_regex[1]
          end

          if line == "bisect run success\n"
            Bummr::Rebaser.instance.remove_commit(sha)
          end
        end
      end
    end
  end
end
