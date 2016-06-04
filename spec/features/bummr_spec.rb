require 'spec_helper'

describe "bummr check", type: :aruba do
  context "run on master branch" do
    # let(:path) { expand_path('%/song.mp3') }

    before :each do
      # cd('.') { FileUtils.cp path, 'file.mp3' }
    end

    before :each do
      run 'bummr check'
    end

    it "returns an error" do 
      expect(all_stdout).to include('Rate is 128 KB') 
    end
  end

  xit "returns an error if bummr is run on master" do
    stub_branch("master")

    bummr.check

    expect(output).to include "Bummr is not meant to be run on master"
    expect(exit_status).to eq 0
  end
end

def bummr
  @bummr ||= Bummr::CLI.new
end

def pass_all_tests

end

def stub_file
  allow(File.file?).with(".bummr-build.sh").to_return { true }
  allow(File.executable?).with(".bummr-build.sh").to_return { true }
end

def stub_branch(branch="update")
  allow(Kernel).to receive(:system).with("git rev-parse --abbrev-ref HEAD") { "#{branch}\n" }
end

def exit_status
  $?.exitstatus
end

# module Kernel
#   module Test
#     def `cmd
#       `cmd`
#     end
#   end
# end
