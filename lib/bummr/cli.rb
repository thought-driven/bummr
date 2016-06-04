require 'bundler'
require 'thor'
require 'open3'
require 'colorize'

module Bummr
  class CLI < Thor
    desc "check", "Run automated checks to see if bummr can be run"
    def check(fullcheck=true)
      errors = []
      
      if `git rev-parse --abbrev-ref HEAD` == "master\n"
        message = "Bummr is not meant to be run on master"
        warn message.red
        say "Please checkout a branch with 'git checkout -b update-gems'"
        errors.push message
      end

      unless File.file?(".bummr-build.sh") && File.executable?(".bummr-build.sh")
        message = "You must have a file '.bummr-build.sh' which runs your build"
        say message.red
        errors.push message
      end

      unless File.directory? "log"
        message = "There is no log directory or you are not in the root"
        say message.red
        errors.push message
      end

      if fullcheck == true
        unless `git diff master`.empty?
          message = "Please make sure that `git diff master` returns empty"
          say message.red
          errors.push message
        end
      end

      if errors.any?
        exit 0
      else
        puts "Ready to run bummr.".green
      end
    end

    desc "update", "Update outdated gems, run tests, bisect if tests fail"
    def update
      say "To run Bummr, you must:"
      say "- Be in the root path of a clean git branch off of master"
      say "- Have no commits or local changes"
      say "- Have a file, '.bummr-build.sh' on master that runs your build"
      say "- Have a 'log' directory, where we can place logs"
      say "- Have your build configured to fail fast (recommended)"
      say "- Have locked any Gem version that you don't wish to update in your Gemfile"
      say "- It is recommended that you lock your versions of `ruby` and `rails in your Gemfile`"

      if yes? "Are you ready to use Bummr? (y/n)"
        check
        `bundle`

        if outdated_gems_to_update.empty?
          say "No outdated gems to update".green
        else
          say "Updating outdated gems:"
          say outdated_gems_to_update.map { |g| "* #{g}" }.join("\n")

          outdated_gems_to_update.each_with_index do |gem, index|
            message = "#{gem[:name]}, {#{gem[:current_version]} -> #{gem[:spec_version]}}"
            say "Updating #{message}, #{index+1} of #{outdated_gems_to_update.count}"

            system("bundle update --source #{gem[:name]}")
            system("git commit -am '#{message}'")
          end

          say "Choose which gems to update"
          system("git rebase -i master")
        end

        test
      else
        say "Thank you!".green
      end
    end

    desc "test", "Test for a successful build and bisect if necesssary"
    def test
      check(false)
      say "Testing the build!".green

      if system("./.bummr-build.sh") == false
        `bundle`
        bisect
      else
        say "Passed the build!".green
        say "See log/bummr.log for details".yellow
        system("cat log/bummr.log")
      end
    end

    desc "bisect", "Find the bad commit, remove it, test again"
    def bisect
      check(false)
      say "Bad commits found! Bisecting...".red
      log "Bad commits found: #{Time.now}"

      system("git bisect start head master")

      Open3.popen2e("git bisect run ./.bummr-build.sh") do |std_in, std_out_err|
        while line = std_out_err.gets
          puts line

          sha_regex = Regexp::new("(.*) is the first bad commit\n").match(line)
          unless sha_regex.nil?
            sha = sha_regex[1]
          end

          if line == "bisect run success\n"
            remove_commit(sha)
          end
        end
      end
    end

    private

    def log(message)
      system("touch log/bummr.log && echo '#{message}' >> log/bummr.log")
    end

    # see bundler/lib/bundler/cli/outdated.rb
    def outdated_gems_to_update
      @gems_to_update ||= begin
        say 'Scanning for outdated gems...'
        gems_to_update = []

        all_gem_specs.each do |current_spec|
          active_spec = bundle_spec(current_spec)
          next if active_spec.nil?

          if spec_outdated?(current_spec, active_spec)
            spec_version    = "#{active_spec.version}#{active_spec.git_version}"
            current_version = "#{current_spec.version}#{current_spec.git_version}"

            gem_to_update = { name: active_spec.name, spec_version: spec_version, current_version: current_version }

            say "Adding #{gem_to_update[:name]} version: #{gem_to_update[:current_version]} to update list"

            gems_to_update << gem_to_update
          end
        end

        gems_to_update.sort_by do |gem|
          gem[:name]
        end
      end
    end

    def remove_commit(sha)
      commit_message = `git log --pretty=format:'%s' -n 1 #{sha}`
      message = "Could not apply: #{commit_message}, #{sha}"

      say message.red
      log message

      say "Resetting..."
      system("git bisect reset")

      say "Removing commit..."
      if system("git rebase -X ours --onto #{sha}^ #{sha}")
        say "Successfully removed bad commit...".green
        say "Re-testing build...".green
        test
      else
        say message.red
        say "Could not automatically remove this commit!".red
        say "Please resolve conflicts, then 'git rebase --continue'."
        say "Run 'bummr test' again once the rebase is complete"
      end
    end

    def spec_outdated?(current_spec, active_spec)
      gem_outdated = Gem::Version.new(active_spec.version) > Gem::Version.new(current_spec.version)
      git_outdated = current_spec.git_version != active_spec.git_version

      gem_outdated || git_outdated
    end

    def bundle_spec(current_spec)
      active_spec = bundle_definition.index[current_spec.name].sort_by { |b| b.version }
      if !current_spec.version.prerelease? && !options[:pre] && active_spec.size > 1
        active_spec = active_spec.delete_if { |b| b.respond_to?(:version) && b.version.prerelease? }
      end
      active_spec.last
    end

    def all_gem_specs
      current_specs = Bundler.ui.silence { Bundler.load.specs }
      current_dependencies = {}
      Bundler.ui.silence { Bundler.load.dependencies.each { |dep| current_dependencies[dep.name] = dep } }
      gemfile_specs, dependency_specs = current_specs.partition { |spec| current_dependencies.has_key? spec.name }
      [gemfile_specs, dependency_specs].flatten.sort_by(&:name)
    end

    def bundle_definition
      @definition ||= begin
        Bundler.definition.validate_ruby!
        definition = Bundler.definition(true)
        definition.resolve_remotely!
        definition
      end
    end
  end
end
