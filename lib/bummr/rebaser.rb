module Bummr
  class Rebaser
    include Singleton

    def remove_commit(sha)
      commit_message = `git log --pretty=format:'%s' -n 1 #{sha}`
      message = "Bad commit: #{commit_message}, #{sha}"
      log message.red

      log "Resetting..."
      system("git bisect reset")

      log "Removing commit..."
      if system("git rebase -X ours --onto #{sha}^ #{sha}")
        log "Successfully removed bad commit...".green
        log "Re-testing build...".green
        system("bummr test")
      else
        log message.red
        log "Could not automatically remove this commit!".red
        log "Please resolve conflicts, then 'git rebase --continue'."
        log "Run 'bummr test' again once the rebase is complete"
      end
    end
  end
end
