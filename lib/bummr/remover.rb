module Bummr
  class Remover < Thor
    include Singleton
    include Log

    desc "remove_commit", "Remove a commit from the history"
    def remove_commit(sha)
      log "Bad commit: #{commit_message_for(sha)}, #{sha}".color(:red)
      log "Resetting..."
      system("git bisect reset")

      if yes? "Would you like to attempt to automatically remove this commit?"
        log "Removing commit..."
        if system("git rebase -p --onto #{sha}^ #{sha} ")
          log "Successfully reverted bad commit...".color(:green)
          log "Re-testing build...".color(:green)
          system("bummr test")
        else
          log "Could not automatically remove this commit!".color(:red)
          log "Please resolve conflicts, then 'git rebase --continue'."
          log "Run 'bummr test' again once the rebase is complete"
        end
      end
    end

    private

    def commit_message_for(sha)
      `git log --pretty=format:'%s' -n 1 #{sha}`
    end
  end
end
