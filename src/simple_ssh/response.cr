struct SimpleSsh::Response
  getter :status
  getter output : String?
  getter error : String?

  def initialize(@status : Process::Status, output = nil, error = nil)
    @output = nil_if_empty(output)
    @error = nil_if_empty(error)
  end

  def self.new(status, output = nil, error = nil)
    new(Process::Status.new(status.to_i), output, error)
  end

  def self.new(response : Array)
    new(response[0], response[1]?, response[2]?)
  end

  private def nil_if_empty(string)
    string = string.try(&.strip)
    string.try(&.empty?.!) ? string : nil
  end
end
