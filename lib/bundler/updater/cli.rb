require 'bundler'
require 'thor'

module Bundler
  module Updater
    class CLI < Thor::Group
      desc "Update outdated gems interactively"
      def update
        if outdated_gems_to_update.empty?
          say "No outdated gems to update"
        else
          say "Updating outdated gems:"
          say outdated_gems_to_update.map { |g| "* #{g}" }.join("\n")
          outdated_gems_to_update.each do |gem|
            message = "#{gem[:name]}, {#{gem[:current_version]} -> #{gem[:spec_version]}}"
            iterations = 2
            say message
            `bundle update #{gem[:name]}`

            iterations.times do |index|
              say "Testing: #{index+1} of #{iterations}"
              `rake`
            end

            say "Passed the build #{iterations} times, committing"

            `git commit -am "#{message}"`
          end
        end
      end

      private

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
end
