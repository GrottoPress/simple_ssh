# Simple SSH

**Simple SSH** enables running commands against a remote host via SSH. It is **not** an implementation of the protocol, but relies on any existing SSH client program installed on the client machine (eg: *OpenSSH*).

*Simple SSH* is stateless, in that a connection is initiated and terminated for every request, after a response is received. Commands can be pipelined, allowing to send multiple commands in a single request.

*Simple SSH* assumes public key authentication, where a client's public key is expected to be listed in the server's `~/.ssh/authorized_keys` file. No other authentication methods are supported at this time.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     simple_ssh:
       github: GrottoPress/simple_ssh
   ```

2. Run `shards install`

## Usage

- Run single command:

  ```crystal
  require "simple_ssh"

  ssh = SimpleSsh.new("root", ip: "127.0.0.1")
  # <= `port:` defaults to '22'

  ssh.run("ls /root") do |response|
    puts response.status.success? # <= true

    response.output.try do |output|
      ouput.each_line { |line| puts line }
    end

    response.error.try do |error|
      error.each_line { |line| puts line }
    end
  end
  ```

- Run multiple (pipelined) commands:

  ```crystal
  require "simple_ssh"

  ssh = SimpleSsh.new("username", "my.host.name", 2222)

  ssh << "ls /root"
  ssh << "cat /non-existent"
  # <= Alias: `ssh.command(...)`

  ssh.run do |responses|
    puts responses.size # <= 2
    # <= Responses follow the order of the commands:
    # <=   `responses[0]` is for "ls /root"
    # <=   `responses[1]` is for "cat /non-existent"

    responses.each do |response|
      puts response.status.exit_code

      response.output.try do |output|
        ouput.each_line { |line| puts line }
      end

      response.error.try do |error|
        error.each_line { |line| puts line }
      end
    end
  end
  ```

## Development

Run tests with `docker-compose run --rm spec`. If you need to update shards before that, run `docker-compose run --rm shards`.

## Contributing

1. [Fork it](https://github.com/GrottoPress/mel/fork)
1. Switch to the `master` branch: `git checkout master`
1. Create your feature branch: `git checkout -b my-new-feature`
1. Make your changes, updating changelog and documentation as appropriate.
1. Commit your changes: `git commit`
1. Push to the branch: `git push origin my-new-feature`
1. Submit a new *Pull Request* against the `GrottoPress:master` branch.
