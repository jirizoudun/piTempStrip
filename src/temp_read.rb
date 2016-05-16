#!/usr/bin/env ruby

require 'fileutils'
require 'socket'
require_relative 'client'

# TODO: Clean the code!

SLEEP_TIME = 1 # Log temperature every x seconds.
SENSORS_DIR = '/sys/bus/w1/devices' # Directory where sensors are readed.
OUTPUT_DIRECTORY = './temp_readings/'

# Configure interface.
def init_sensor
  `modprobe w1-gpio`
  `modprobe w1-therm`
end 

# Function for getting temperature from given file content.
# Temperature is in content with format 't=26500' which means 26.5.
# Content contains some other information that aren't important for us.
def temp(content)
  index = content.index 't='
  content[index+2, content.length].to_i / 1000.0
end

# Returns sensor name for reading.
def sensor_name
  base_dir = Dir.new SENSORS_DIR

  # Directory for given sensor starts with prefix '28' and then there's
  # some identifier.
  sensor_names = base_dir.grep /^28*/ # Find sensors/

  if sensor_names.count <= 0
    STDERR.puts 'No sensor found. Aborting..'
    abort
  end

  # Use first sensor only.
  # TODO: Use more than one sensor.
  base_dir.path + '/' + sensor_names.first
end

# Writes a temperature to the file as backup solution.
# Files are written by days (which can cause problems when RPI has no
# internet connection -> no time).
def print_to_file(temp)
  time = Time.new

  FileUtils.mkdir_p OUTPUT_DIRECTORY
  
  open(OUTPUT_DIRECTORY + time.strftime("%Y%m%d") + '.temp', 'a') do |f|
    f << time.strftime("%H%M%S") + ';' + temp.to_s + "\n"
  end
end

# SCRIPT
p 'Temperature reading from DS18B20 sensor..'
init_sensor

while
  # Read the content of the file which contains current temperature from
  # the sensor.
  content = File.read(sensor_name + '/w1_slave')

  # 'YES' in the content indicates that temperature is readable. For
  # more info see DS18B20 datasheet or some tutorial for RPI and DS18B20.
  unless content.include? 'YES'
    p 'No successful reading..'
    sleep 0.2
    next
  end

  # Read a temperature from the file content.
  t = temp(content)

  p t

  # Printing temperature to the file (backup variant maybe?)
  print_to_file t

  # TODO: Client side sending of temperature.
  begin
    client = Client.new('living-room', 'localhost', 23457)
    client.record(t)
    client.close
  rescue Errno::ECONNREFUSED
    p 'Connection to server refused'
  end

  sleep SLEEP_TIME
end


