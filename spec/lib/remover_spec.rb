require "spec_helper"

describe Bummr::Remover do
  # let(:commit_message) { "test commit message" }
  let(:remover) { Bummr::Remover.instance }
  let(:sha) { "testsha" }
  let(:remove_command) { "git rebase -p --onto #{sha}^ #{sha}" }

  before do
    allow(remover).to receive(:commit_message_for).and_return "commit message"
    allow(remover).to receive(:log)
    allow(remover).to receive(:system)
    allow(remover).to receive(:yes?).and_return(true)
  end

  describe "#remove_commit" do
    it "logs the bad commit" do
      remover.remove_commit(sha)

      expect(remover).to have_received(:log).with(
        "Bad commit: commit message, #{sha}".color(:red)
      )
    end

    it "resets the bisection" do
      remover.remove_commit(sha)

      expect(remover).to have_received(:system).with("git bisect reset")
    end
  end
end
