require 'open3'

module Bummr
  class Outdated
    def initialize(file_reader: File)
      @file_reader = file_reader
    end

    def outdated_gems(all_gems: false)
      results = []

      options = []
      options << "--strict" unless all_gems

      Open3.popen2("bundle outdated", *options) do |_std_in, std_out|
        while line = std_out.gets
          puts line
          gem = parse_gem_from(line)

          if gem && (all_gems || gemfile_contains(gem[:name]))
            results.push gem
          end
        end
      end

      results
    end

    def parse_gem_from(line)
      regex = / \* (.*) \(newest (\d[\d\.]*\d)[,\s] installed (\d[\d\.]*\d)[\),\s]/.match line

      unless regex.nil?
        { name: regex[1], newest: regex[2], installed: regex[3] }
      end
    end

    private

    attr_reader :file_reader

    def gemfile_contains(gem_name)
      /gem ['"]#{gem_name}['"]/.match gemfile
    end

    def gemfile
      @gemfile ||= file_reader.read("Gemfile")
    end
  end
end
