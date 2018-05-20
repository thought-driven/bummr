module Bummr
  module Prompt
    def yes?(*args)
      headless? || super
    end

    private

    def headless?
      HEADLESS == true ||
        HEADLESS == "true"
    end
  end
end
