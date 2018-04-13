module Bummr
  class Remover < Thor
    include Singleton
    include Log

    desc "remove_commit", "Remove a commit from the history"
    def remove_commit(sha)
      log "Bad commit: #{commit_message_for(sha)}, #{sha}".color(:red)
      log "Resetting..."
      system("git bisect reset")

      message = "\nThe commit:\n\n `#{sha} #{commit_message_for(sha)}`\n\n" +
        "Is breaking the build.\n\n" +
        "Please do one of the following: \n\n" +
        " 1. Update your code to work with the latest version of this gem.\n\n" +
        " 2. Perform the following steps to lock the gem version:\n\n" +
        "    - `git reset --hard master`\n" +
        "    - Lock the version of this Gem in your Gemfile.\n" +
        "    - Commit the changes.\n" +
        "    - Run `bummr update` again.\n\n" +
        "Lord Bummr\n\n"

      puts message.color(:yellow)
    end

    private

    def commit_message_for(sha)
      `git log --pretty=format:'%s' -n 1 #{sha}`
    end
  end
end
