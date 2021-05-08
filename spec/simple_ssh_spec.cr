require "./spec_helper"

describe SimpleSsh do
  describe "#command" do
    it "pipelines multiple commands" do
      ssh = SimpleSsh.new(**BOX)

      ssh << "ls /root"
      ssh << "cat /non-existent"

      ssh.run do |responses|
        responses.size.should eq(2)
        responses[0].status.success?.should be_true
        responses[1].status.success?.should be_false
        responses[1].error.should_not be_nil
      end
    end
  end

  describe "#run" do
    it "discards previous commands" do
      ssh = SimpleSsh.new(**BOX)

      ssh << "ls /root"
      ssh.run.size.should eq(1)

      ssh << "ls /root"
      ssh.run.size.should eq(1)
    end

    context "single command" do
      it "runs" do
        ssh = SimpleSsh.new(**BOX)
        response = ssh.run("ls /root")
        response.status.success?.should be_true
      end

      it "discards previous commands" do
        ssh = SimpleSsh.new(**BOX)

        ssh << "cat /non-existent"
        ssh.run.first.status.success?.should be_false

        ssh << "cat /non-existent"
        ssh.run("ls /root") do |response|
          response.status.success?.should be_true
        end
      end
    end
  end
end
