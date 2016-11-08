require "simplecov"

# https://circleci.com/docs/code-coverage/
if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start

require 'pry'
require 'bummr'
require 'colorize'
