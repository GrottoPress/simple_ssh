require "socket"

require "./simple_ssh/version"
require "./simple_ssh/**"

class SimpleSsh
  getter :user, :host, :port

  def initialize(@user : String, @host : String, @port = 22)
    @commands = Array(String).new
    @buffer = Array(String).new
    @separator = %q[::=SIMPLESSH=::]
  end

  def self.new(user : String, *, ip : String, port = 22)
    new(user, Socket::IPAddress.new(ip, port.to_i))
  end

  def self.new(user : String, ip : Socket::IPAddress)
    new(user, ip.address, ip.port)
  end

  def <<(command)
    command(command)
  end

  def command(command : String)
    @commands << command

    random = `echo ${RANDOM}`.strip
    timestamp = `date +"%s"`.strip

    stderr = "/tmp/simplessh-stderr-#{timestamp}-#{random}.txt"
    devnull = "/dev/null"

    @buffer << echo_separator
    @buffer << "simplessh_output=$(#{command} 2>#{stderr})"
    @buffer << "simplessh_status=${?}"
    @buffer << "simplessh_error=$(cat #{stderr} 2>#{devnull})"
    @buffer << "rm #{stderr} 2>#{devnull} 1>#{devnull}"

    @buffer << "echo -n ${simplessh_status}"
    @buffer << echo_separator
    @buffer << %[echo -n "${simplessh_output}"]
    @buffer << echo_separator
    @buffer << %[echo -n "${simplessh_error}"]

    self
  end

  def run
    run { |responses| responses }
  end

  def run
    add_host
    @buffer << echo_separator

    output = `ssh -Tp #{port} '#{user}'@'#{host}' <<'SSH'\n\
    #{@buffer.join("; ")}\n\
    SSH`

    responses = responses(output, $?)

    responses.each_with_index do |response, i|
      log_error(response, @commands[i])
    end

    clear_buffer

    yield responses
  end

  def run(command : String) : Response
    run(command) { |response| response }
  end

  def run(command : String)
    clear_buffer
    self << command
    run { |responses| yield responses[0] }
  end

  private def add_host
    `[ -z "$(ssh-keygen -F '#{host_port}')"] && \
      ssh-keyscan -Hp #{port} '#{host}' >> ~/.ssh/known_hosts`
  end

  private def responses(output, status)
    unless status.success?
      raise Error.new("SSH connection failed for #{host_port}")
    end

    output.split(@separator)[1..-2]
      .each_slice(3)
      .map { |triple| Response.new(triple) }
      .to_a
  end

  private def host_port
    "[#{host}]:#{port}"
  end

  private def log_error(response, command)
    return if response.status.success?

    self.class.log.error &.emit(
      "SSH command failed",
      host: host,
      port: port,
      user: user,
      command: command,
      status: response.status.exit_code,
      error: response.error || response.output
    )
  end

  private def clear_buffer
    @commands.clear
    @buffer.clear
  end

  private def echo_separator
    "echo -n '#{@separator}'"
  end
end
