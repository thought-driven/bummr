require 'spec_helper'

describe Bummr::Check do
  let(:check) { Bummr::Check.instance }

  describe "#check" do
    before do
      allow(check)
        .to receive(:check_master).and_return(nil)
      allow(check)
        .to receive(:check_log).and_return(nil)
      allow(check)
        .to receive(:check_status).and_return(nil)
      allow(check)
        .to receive(:check_diff).and_return(nil)
      allow(check)
        .to receive(:puts)
      allow(check).to receive(:yes?)
    end

    context "all checks pass" do
      context "not full check" do
        it "returns 'Ready to run bummr.' and proceeds" do
          check.check(false)

          expect(check).to have_received(:puts).with("Ready to run bummr.".green)
        end
      end

      context "full check" do
        it "returns 'Ready to run bummr.' and proceeds" do
          check.check(true)

          expect(check).to have_received(:puts).with("Ready to run bummr.".green)
        end
      end
    end

    context "check_master fails" do
      before do
        allow(check).to receive(:check_master)
          .and_call_original
        allow(check).to receive(:`).with('git rev-parse --abbrev-ref HEAD')
          .and_return "master\n"
      end

      it "reports the error" do
        check.check

        expect(check).to have_received(:puts)
          .with("Bummr is not meant to be run on master".red)
      end
    end

    context "check_log fails" do
      before do
        allow(check).to receive(:check_log)
          .and_call_original
        allow(File).to receive(:directory?).with('log')
          .and_return false
      end

      it "reports the error" do
        check.check

        expect(check).to have_received(:puts)
          .with("There is no log directory or you are not in the root".red)
      end
    end

    context "check_status fails" do
      context "due to bisecting" do
        before do
          allow(check).to receive(:check_status)
            .and_call_original
          allow(check).to receive(:`).with('git status')
            .and_return "are currently bisecting"
        end

        it "reports the error" do
          check.check

          expect(check).to have_received(:puts)
            .with("You are already bisecting. Make sure `git status` is clean".red)
        end
      end

      context "due to rebasing" do
        before do
          allow(check).to receive(:check_status)
            .and_call_original
          allow(check).to receive(:`).with('git status')
            .and_return "are currently rebasing"
        end

        it "reports the error" do
          check.check

          expect(check).to have_received(:puts)
            .with("You are already rebasing. Make sure `git status` is clean".red)
        end
      end
    end

    context "check_diff fails" do
      before do
        allow(check).to receive(:check_diff)
          .and_call_original
        allow(check).to receive(:`).with('git diff master')
          .and_return "+ file"
      end

      it "reports the error" do
        check.check

        expect(check).to have_received(:puts)
          .with("Please make sure that `git diff master` returns empty".red)
      end
    end
  end
end
