#!/usr/bin/env ruby

# TODO: Clean the code!

SLEEP_TIME = 60*10 # Log temperature every 10 mins

# Function for printing temperature from given file content.
def temp(content)
  index = content.index 't='
  content[index+2, content.length].to_i / 1000.0
end

p 'Temperature reading from DS18B20 sensor..'

# Configure interface.
`modprobe w1-gpio`
`modprobe w1-therm`

base_dir = Dir.new '/sys/bus/w1/devices'

sensor_names = base_dir.grep /^28*/ # Find sensors/

if sensor_names.count <= 0
  STDERR.puts 'No sensor found. Aborting..'
  abort
end

# Use first sensor only.
# TODO: Use more than one sensor.
sensor_name = sensor_names.first

while
  
  content = File.read( base_dir.path + '/' +
              sensor_name + '/w1_slave')
              
  if content.include? 'YES'
    t = temp(content)
    p t

    open('temperature.out', 'a') do |f|
      f << Time.now.to_s + ';' + t.to_s + "\n"
    end
    
    sleep SLEEP_TIME
  else
    p 'No successful reading..'
    sleep 0.2
  end

end


