require "../spec_helper"

describe SimpleSsh::Response do
  it "works" do
    status = Process::Status.new(1)
    output = "output"
    error = "error"

    response = SimpleSsh::Response.new(status, output, error)

    response.status.should eq(status)
    response.output.should eq(output)
    response.error.should eq(error)
  end

  it "can be constructed from an integer" do
    response = SimpleSsh::Response.new(2)

    response.status.exit_status.should eq(2)
  end

  it "can be constructed from a string" do
    response = SimpleSsh::Response.new("2")

    response.status.exit_status.should eq(2)
  end

  it "can be constructed from an array" do
    status = 2
    output = "output"
    error = "error"

    response = SimpleSsh::Response.new([status.to_s, output, error])

    response.status.exit_status.should eq(status)
    response.output.should eq(output)
    response.error.should eq(error)
  end

  it "returns 'nil' for empty strings" do
    response = SimpleSsh::Response.new(1, "\n ", " \n")

    response.status.exit_status.should eq(1)
    response.output.should be_nil
    response.error.should be_nil
  end
end
