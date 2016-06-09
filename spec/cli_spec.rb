require 'spec_helper'

describe Bummr::CLI do
  # https://github.com/wireframe/gitx/blob/171da367072b0e82d5906d1e5b3f8ff38e5774e7/spec/thegarage/gitx/cli/release_command_spec.rb#L9
  let(:args) { [] }
  let(:options) { {} }
  let(:config) do
    {
      pretend: true
    }
  end
  let(:cli) { described_class.new(args, options, config) }
  let(:outdated_gems) {
    [
      { name: "myGem", installed: "0.3.2", current: "0.3.5" },
      { name: "otherGem", installed: "1.3.2.23", current: "1.6.5" },
      { name: "thirdGem", installed: "4.3.4", current: "5.6.45" },
    ]
  }

  describe "#update" do
    context "when user rejects moving forward" do
      it "does not attempt to move forward" do
        expect(cli).to receive(:yes?).and_return(false)
        expect(cli).not_to receive(:check)

        cli.update
      end
    end

    context "when user agrees to move forward" do
      context "and there are no outdated gems" do
        it "informs that there are no outdated gems" do
          allow_any_instance_of(Bummr::Outdated).to receive(:outdated_gems)
            .and_return []

          expect(cli).to receive(:ask_questions)
          expect(cli).to receive(:yes?).and_return(true)
          expect(cli).to receive(:check)
          expect(cli).to receive(:log)
          expect(cli).to receive(:system).with("bundle")
          expect(cli).to receive(:puts).with("No outdated gems to update".green)

          cli.update
        end
      end

      context "and there are outdated gems" do
        it "calls 'update' on the updater" do
          allow_any_instance_of(Bummr::Outdated).to receive(:outdated_gems)
            .and_return outdated_gems
          updater = double
          allow(updater).to receive(:update_gems)

          expect(cli).to receive(:ask_questions)
          expect(cli).to receive(:yes?).and_return(true)
          expect(cli).to receive(:check)
          expect(cli).to receive(:log)
          expect(cli).to receive(:system).with("bundle")
          expect(Bummr::Updater).to receive(:new).with(outdated_gems).and_return updater
          expect(cli).to receive(:system).with("git rebase -i master")
          expect(cli).to receive(:test)

          cli.update
        end
      end
    end
  end
end

