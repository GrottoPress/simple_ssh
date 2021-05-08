require "log"

struct SimpleSsh
  def self.log
    @@log ||= Log.for(self)
  end
end
