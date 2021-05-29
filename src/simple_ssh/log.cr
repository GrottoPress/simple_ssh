require "log"

class SimpleSsh
  def self.log
    @@log ||= Log.for(self)
  end
end
