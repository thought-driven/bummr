require "spec_helper"

describe Bummr::Git do
  describe "#add" do
    it "stages specified files with git" do
      git = stub_git
      files = "Gemfile Gemfile.lock"

      git.add(files)

      expect(git).to have_received(:system).with(
        "git add #{files}"
      )
    end
  end

  describe "#commit" do
    it "logs the commit" do
      git = stub_git
      commit_message = "Update Foo from 0.0.1 to 0.0.2"

      git.commit(commit_message)

      expect(git).to have_received(:log).with(
        /Commit: #{commit_message}/
      )
    end

    it "commits with a message" do
      git = stub_git
      commit_message = "Update Foo from 0.0.1 to 0.0.2"

      git.commit(commit_message)

      expect(git).to have_received(:system).with(
        "git commit -m '#{commit_message}'"
      )
    end

    describe "when BUMMR_GIT_COMMIT is defined" do
      it "commits using defined value" do
        allow(ENV).to receive(:fetch).with("BUMMR_GIT_COMMIT").and_return("git commit --no-verify")
        git = stub_git
        commit_message = "Update Foo from 0.0.1 to 0.0.2"

        git.commit(commit_message)

        expect(git).to have_received(:system).with(
          "git commit --no-verify -m '#{commit_message}'"
        )
      end
    end
  end

  def stub_git
    git = Bummr::Git.clone.instance
    allow(git).to receive(:log)
    allow(git).to receive(:system)
    git
  end
end
