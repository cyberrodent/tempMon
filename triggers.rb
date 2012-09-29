
class Graphite < Trigger
    def trigger(key, val)
        date = Time.now.to_i
        value = val.to_i
        puts %Q{echo  "#{key} #{value} #{date}" | nc #{@host} #{@port}}
        %x{echo  "#{key} #{value} #{date}" | nc #{@host} #{@port}}
    end
end

require "socket"

class Statsd < Trigger
    def trigger(key, val)
        # statsd way i like it
        s = UDPSocket.new
        s.send("#{key}:#{val}|g", 0, @host, @port)
    end
end
