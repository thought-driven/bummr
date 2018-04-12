require "spec_helper"

describe Bummr::Remover do
  # let(:commit_message) { "test commit message" }
  let(:remover) { Bummr::Remover.instance }
  let(:sha) { "testsha" }
  let(:remove_command) { "git revert #{sha} --no-edit" }

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

    context "successfully reverts the commit" do
      before(:each) do
        allow(remover).to receive(:system).with(remove_command).and_return true
        allow(remover).to receive(:yes?).and_return true
      end

      it "logs the successful result" do
        remover.remove_commit(sha)

        expect(remover).to have_received(:log).with(
          "Successfully reverted bad commit...".color(:green)
        )
      end
    end

    context "fails to revert the commit" do
      before(:each) do
        allow(remover).to receive(:system).with(remove_command).and_return false
      end

      it "logs the failure" do
        remover.remove_commit(sha)

        expect(remover).to have_received(:log).with(
          "Could not automatically remove this commit!".color(:red)
        )
      end
    end
  end
end
