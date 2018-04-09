module ActionDispatch
  class Reloader
    def self.prepare!
      ActiveSupport::Reloader.prepare!
    end

    def self.cleanup!
      ActiveSupport::Reloader.cleanup!
    end
  end
end
