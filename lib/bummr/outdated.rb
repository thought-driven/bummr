require 'open3'
require 'singleton'

module Bummr
  class Outdated
    include Singleton

    def outdated_gems
      @outdated_gems ||= begin
        results = []

        Open3.popen2("bundle outdated --strict") do |std_in, std_out|
          while line = std_out.gets
            puts line
            gem = parse_gem_from(line)

            if gem && gemfile_contains(gem[:name])
              results.push gem
            end
          end
        end

        results
      end
    end

    def parse_gem_from(line)
      regex = / \* (.*) \(newest (\d[\d\.]*\d)[,\s] installed (\d[\d\.]*\d)[\),\s]/.match line

      unless regex.nil?
        { name: regex[1], newest: regex[2], installed: regex[3] }
      end
    end

    def gemfile_contains(gem_name)
      /gem ['"]#{gem_name}['"]/.match gemfile
    end

    def gemfile
      @gemfile ||= `cat Gemfile`
    end
  end
end
