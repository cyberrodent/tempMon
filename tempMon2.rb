# !/home/jkolber/.rvm/rubies/ruby-1.9.2-p318/bin/ruby

require "socket"

class TempMon
    attr_accessor :statsHost
    attr_accessor :graphitePort
    attr_accessor :statsdPort
    attr_accessor :graphite_key
    attr_accessor :temp2_threshhold
    attr_accessor :too_cool

    def initialize()
        self.statsHost = "192.168.1.200"
        self.graphitePort = 2003
        self.statsdPort = 8125
        self.temp2_threshhold = 47
        self.too_cool = 42.5
        self.graphite_key = "macmini.sensors"

    end

    ##
    # Public
    #
    def toGraphite(key, val)
        date = Time.now.to_i
        value = val.to_i
        puts  "#{self.graphite_key}.#{key} #{val} #{date} | nc #{self.statsHost} #{self.graphitePort} "
        %x{echo  "#{self.graphite_key}.#{key} #{val} #{date}" | nc #{self.statsHost} #{self.graphitePort} }

    end

    ##
    # Public
    #
    def toStatsd(key, val)
        s = UDPSocket.new
        s.send("#{graphite_key}.#{key}:#{val}|g", 0, self.statsHost, self.statsdPort)
    end

    ##
    # readSensors
    #
    def readSensors()
        wasCore = 0
        sensor_in = `sensors -u`

        out = {}
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

            probe = /(?<key>[a-zA-Z0-9_]+):\s(?<value>[0-9\.]+)/.match(line)
            if probe
                # puts probe[:key] 
                # puts "----"
                # puts probe[:value]

                out[probe[:key]] = probe[:value]
                toGraphite(probe[:key], probe[:value])
                toStatsd(probe[:key], probe[:value])
            end
        end

        return out
    end
end

class FanControl
    def get_current()
        `cat /sys/devices/platform/applesmc.768/fan1_output`
    end

    def fan_medium()
        `echo 1 > /sys/devices/platform/applesmc.768/fan1_manual`
        `echo 4200 > /sys/devices/platform/applesmc.768/fan1_output`
    end

    def fan_low()
        `echo 1 > /sys/devices/platform/applesmc.768/fan1_manual`
        `echo 3200 > /sys/devices/platform/applesmc.768/fan1_output`
    end


    def fan_high()
        `echo 1 > /sys/devices/platform/applesmc.768/fan1_manual`
        `echo 5100 > /sys/devices/platform/applesmc.768/fan1_output`
    end
end


if __FILE__ == $0

    t = TempMon.new
    fc = FanControl.new

    # puts t.statsHost
    temps = t.readSensors()


    puts "Temp is #{temps['temp2_input']}."


    if temps['temp2_input'].to_f > t.temp2_threshhold
        # puts "TOO HOT"
        fc.fan_high() 
        t.toGraphite("fan.high", 1)

    elsif temps['temp2_input'].to_f < t.too_cool
        # puts "TOO COOL"
        fc.fan_low()
        t.toGraphite("fan.low", 1);

    else 
        # puts "JUST RIGHT"
        fc.fan_medium()
        t.toGraphite("fan.medium", 1)
    end

    current_speed = fc.get_current().strip!
    t.toGraphite("fan.speed", current_speed)
end

