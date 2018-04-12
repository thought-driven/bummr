require "spec_helper"

describe Bummr::Rebaser do
  # let(:commit_message) { "test commit message" }
  let(:rebaser) { Bummr::Rebaser.instance }
  let(:sha) { "testsha" }
  let(:rebase_command) { "git rebase -X ours --onto #{sha}^ #{sha}" }

  before do
    allow(rebaser).to receive(:commit_message_for).and_return "commit message"
    allow(rebaser).to receive(:log)
    allow(rebaser).to receive(:system)
    allow(rebaser).to receive(:yes?).and_return(true)
  end

  describe "#remove_commit" do
    it "logs the bad commit" do
      rebaser.remove_commit(sha)

      expect(rebaser).to have_received(:log).with(
        "Bad commit: commit message, #{sha}".color(:red)
      )
    end

    it "resets the bisection" do
      rebaser.remove_commit(sha)

      expect(rebaser).to have_received(:system).with("git bisect reset")
    end

    context "successfully rebases the commit out" do
      before(:each) do
        allow(rebaser).to receive(:system).with(rebase_command).and_return true
        allow(rebaser).to receive(:yes?).and_return true
      end

      it "logs the successful result" do
        rebaser.remove_commit(sha)

        expect(rebaser).to have_received(:log).with(
          "Successfully removed bad commit...".color(:green)
        )
      end

      it "tests the build again" do
        rebaser.remove_commit(sha)

        expect(rebaser).to have_received(:system).with "bummr test"
      end
    end

    context "fails to rebase the commit out" do
      before(:each) do
        allow(rebaser).to receive(:system).with(rebase_command).and_return false
      end

      it "logs the  failure to rebase" do
        rebaser.remove_commit(sha)

        expect(rebaser).to have_received(:log).with(
          "Could not automatically remove this commit!".color(:red)
        )
      end
    end
  end
end
