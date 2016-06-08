module Bummr
  class Updater
    include Singleton

    def update_gems(outdated_gems)
      say "Updating outdated gems".green

      outdated_gems.each_with_index do |gem, index|
        update_gem(gem, index)
      end

    end

    def update_gem(gem, index)
      say "Updating #{gem[:name]}: #{index+1} of #{outdated_gems.count}"
      system("bundle update --source #{gem[:name]}")

      updated_version = updated_version_for(gem)
      message = "Update #{gem[:name]} from #{gem[:installed]} to #{updated_version}"

      if gem[:newest] != updated_version
        log("#{gem[:name]} not updated from #{gem[:installed]} to latest: #{gem[:newest]}")
      end

      unless gem[:installed] == updated_version
        say message.green
        system("git commit -am '#{message}'")
      else
        log("#{gem[:name]} not updated")
      end
    end

    def updated_version_for(gem)
      `bundle list | grep " #{gem[:name]} "`.split('(')[1].split(')')[0]
    end
  end
end

