#!/usr/bin/env ruby

require 'socket'

class Client
  def initialize(name, host, port)
    @name = name
    @server = TCPSocket.open(host, port)
  end

  def record(temp)
    @server.puts "RECORD #{@name} #{temp}"
  end

  def read(count)
    @server.puts "READ #{@name} #{count}"
    @server.gets.split(' ')
  end

  def close
    @server.puts '0'
    @server.close
  end
end

# example/testing, REMOVE later
if __FILE__ == $0
  client = Client.new('living-room', 'localhost', 23457)
  client.read(12)
  client.close
end
