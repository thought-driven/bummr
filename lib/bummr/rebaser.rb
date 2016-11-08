module Bummr
  class Rebaser
    include Singleton
    include Log

    def remove_commit(sha)
      log "Bad commit: #{commit_message_for(sha)}, #{sha}".color(:red)
      log "Resetting..."
      system("git bisect reset")

      log "Removing commit..."
      if system("git rebase -X ours --onto #{sha}^ #{sha}")
        log "Successfully removed bad commit...".color(:green)
        log "Re-testing build...".color(:green)
        system("bummr test")
      else
        log "Could not automatically remove this commit!".color(:red)
        log "Please resolve conflicts, then 'git rebase --continue'."
        log "Run 'bummr test' again once the rebase is complete"
      end
    end

    private

    def commit_message_for(sha)
      `git log --pretty=format:'%s' -n 1 #{sha}`
    end
  end
end
