module Bummr
  class Git
    include Singleton
    include Log

    def initialize
      @git_commit = ENV.fetch("BUMMR_GIT_COMMIT") { "git commit" }
    end

    def commit(message)
      system("#{git_commit} -am '#{message}'")
    end

    private

    attr_reader :git_commit
  end
end
