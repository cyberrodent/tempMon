#
# tempMon
# read temperature data from lm-sensors and squirt it into graphite
#
#

require "socket"

def toGraphite(key, value)
    gHost = "localhost"
    gPort = "2003"
    date = Time.now.to_i
    value = value.to_i
    `echo "macmini.sensors.#{key} #{value} #{date}" | nc -w 1 #{gHost} #{gPort}`
end


def toStatsd(key, value)
    sHost = "127.0.0.1"
    sPort = "8125"
    value = value.to_i
    s = UDPSocket.new
    s.send("macmini.sensors.#{key}:#{value}|g", 0, sHost, sPort)

end

wasCore = 0
sensor_in = `sensors -u`
sensor_in.split(/\r?\n/).each do | line | 
    # some of these keys occurr more than once
    # and we can skip the one that  comes after Core 0:
    if wasCore == 1
        wasCore = 0
        next
    end
    if line == "Core 0:"
        wasCore = 1
        next
    end
    probe = /(?<key>[a-zA-Z0-9_]+):\s(?<value>[0-9.]+)/.match(line)
    if probe
        # puts probe[:key]
        # puts "----"
        # puts probe[:value]
        toGraphite(probe[:key], probe[:value])
        toStatsd(probe[:key], probe[:value])

    end
end
