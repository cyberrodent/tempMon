# !/home/jkolber/.rvm/rubies/ruby-1.9.2-p318/bin/ruby

require "socket"

class TempMon
    attr_accessor :statsHost
    attr_accessor :graphitePort
    attr_accessor :statsdPort
    attr_accessor :graphite_key



    def initialize()
        # These properties are all about to where we send data 
        self.statsHost = "192.168.1.1"
        self.statsdPort = 8125
        self.graphitePort = 2003
        self.graphite_key = "my.sensors"
    end

    ##
    # Public
    #
    def toGraphite(key, val)
        date = Time.now.to_i
        value = val.to_i
        # puts  "#{self.graphite_key}.#{key} #{val} #{date} | nc #{self.statsHost} #{self.graphitePort} "
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


