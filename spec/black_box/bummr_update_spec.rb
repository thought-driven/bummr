require "spec_helper"
require "jet_black"

describe "bummr update command" do
  let(:session) { JetBlack::Session.new(options: { clean_bundler_env: true }) }
  let(:bummr_gem_path) { File.expand_path("../../", __dir__) }

  it "updates outdated gems" do
    session.create_file "Gemfile", <<~RUBY
      source "https://rubygems.org"
      gem "rake", "~> 10.0"
      gem "bummr", path: "#{bummr_gem_path}"
    RUBY

    session.create_file "Rakefile", <<~RUBY
      task :say_hi do
        puts "Hello from the Rakefile"
      end

      task default: :say_hi
    RUBY

    expect(session.run("bundle install")).
      to be_a_success.and have_stdout(/bummr .* from source/)

    # Now allow newer versions of Rake to be installed
    session.run("sed -i.bak 's/, \"~> 10.0\"//' Gemfile")

    session.run("mkdir -p log")
    session.run("git init .")
    session.run("git add .")
    session.run("git commit -m 'Initial commit'")
    session.run("git checkout -b bummr-branch")

    update_result = session.run(
      "bundle exec bummr update",
      stdin: "y\ny\ny\n",
      env: { EDITOR: nil },
    )

    rake_gem_updated = /Update rake from 10\.\d\.\d to 1[1-9]\.\d\.\d/

    expect(update_result).
      to be_a_success.and have_stdout(rake_gem_updated)

    expect(update_result).to have_stdout("Passed the build!")

    expect(session.run("git log")).
      to be_a_success.and have_stdout(rake_gem_updated)

    expect(session.run("bundle show")).
      to be_a_success.and have_stdout(/rake\s\(1[1-9]/)

    expect(session.run("bundle exec rake")).
      to be_a_success.and have_stdout("Hello from the Rakefile")
  end
end
