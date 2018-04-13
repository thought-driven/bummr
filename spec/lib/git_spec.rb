require "spec_helper"

describe Bummr::Git do
  describe "#commit" do
    it "commits with a message" do
      git = stub_git
      commit_message = "Update Foo from 0.0.1 to 0.0.2"

      git.commit(commit_message)

      expect(git).to have_received(:system).with(
        "git commit -am '#{commit_message}'"
      )
    end

    describe "when BUMMR_GIT_COMMIT is defined" do
      it "commits using defined value" do
        allow(ENV).to receive(:fetch).with("BUMMR_GIT_COMMIT").and_return("git commit --no-verify")
        git = stub_git
        commit_message = "Update Foo from 0.0.1 to 0.0.2"

        git.commit(commit_message)

        expect(git).to have_received(:system).with(
          "git commit --no-verify -am '#{commit_message}'"
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
