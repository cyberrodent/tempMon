class Sensors 

    @sensor_in 

    def initialize()

    end

    def report()

        sensor_in = `sensors -u`
        out = {}
        wasCore = 0
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
            end
        end
        return out
    end
end
