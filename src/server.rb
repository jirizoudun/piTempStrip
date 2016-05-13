#!/usr/bin/env ruby

require 'socket'
require 'sequel'

class Server
  def initialize(database, port, hostname='127.0.0.1')
    puts "Starting server at #{hostname}:#{port}, using database #{database}"

    @server = TCPServer.new(hostname, port)

    @db = Sequel.sqlite database

    @db.create_table? :temps do
      Integer :timestamp
      String :name, :size => 15
      Float :temp
      primary_key [:timestamp, :name]
    end

    @db.create_table? :setup do
      String :name, :size => 15, :primary_key => true
      String :grouping, :size => 6, :null => true # none, minute, hour, day, week, month
      String :mode, :fixed => true, :size => 3, :null => true # avg, min, max
    end
  end

  def run
    puts 'Server ready, waiting for clients'

    loop do
      Thread.start(@server.accept) do |client| # not too effective, but we're not building robust server
        puts 'Client connected'

        loop do
          message = client.gets
          break if message.nil?

          message.rstrip!
          break if message == '0'

          begin
            parse_message client, message
          rescue Exception => e
            puts '# ' + e.message
            puts e.backtrace
          end
        end

        client.close
        puts 'Client disconnected'
      end
    end
  end

  private

  def parse_message(client, message)
    puts "# received #{message}"

    # m = message.setup/^SETUP (\S+?) (\d+(\.\d+)?)$/

    m = message.match /^RECORD (\S+?)\s+(-?\d+(\.\d+)?)$/
    return record m[1], m[2] unless m.nil?

    m = message.match /^READ (\S+?)\s+(\d+)$/
    client.puts(read m[1], m[2]) unless m.nil?
  end

  def setup(name, grouping, mode)
    @db[:setup].replace(
      name: name,
      grouping: grouping,
      mode: mode
    )
  end

  def record(name, temperature)
    @db[:temps].replace(
      timestamp: Time.now.to_i,
      name: name,
      temp: temperature
    )
  end

  def read(name, limit, grouping='none', mode=nil)

    setup = @db[:setup].where(:name => name)
    if setup.count != 0
      grouping = setup[:grouping]
      mode = setup[:mode]
    end

    key = case grouping
            when 'minute'
              '%Y%m%d%H%M'
            when 'hour'
              '%Y%m%d%H'
            when 'day'
              '%Y%m%d'
            when 'week'
              '%Y%m%W'
            when 'month'
              '%Y%m'
            else
              '%s'
            end

    value = case mode
              when 'min', 'max', 'avg'
                Sequel.function(mode.to_sym, :temp)
              else
                :temp
            end

    @db[:temps]
      .select(
        Sequel.as(Sequel.function(:strftime, key, :timestamp, 'unixepoch'), :time),
        Sequel.as(value, :temp)
      )
      .where(name: name)
      .reverse_order(:timestamp)
      .group(:time)
      .limit(limit)
      .to_hash(:time, :temp)
      .values
      .join(' ')
  end
end

if __FILE__ == $0
  # this will only run if the script was the main, not load'd or require'd

  if ARGV.count < 2
    puts 'Usage: .\server.rb dbname port [host]'
    exit
  end

  if ARGV.count == 2
    server = Server.new ARGV[0], ARGV[1]
  else
    server = Server.new ARGV[0], ARGV[1]
  end
  server.run
end