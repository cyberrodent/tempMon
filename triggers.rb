
class Graphite < Trigger
    def trigger(key, val)
        date = Time.now.to_i
        value = val.to_i
        puts %Q{echo  "#{key} #{value} #{date}" | nc #{@@host} #{@@port} }
#        %x{echo  "#{key} #{val} #{date}" | nc #{self.host} #{self.port} }
    end
end

class Statsd < Trigger
    def trigger(key, val)
        puts "statsd way i like it"
    end
end
