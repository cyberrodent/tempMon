# !/home/jkolber/.rvm/rubies/ruby-1.9.2-p318/bin/ruby

require "./lib/TempMon.rb"
require "./lib/FanControl.rb"
require "./lib/Sensors.rb"
require "./lib/Trigger.rb"
require "./triggers.rb"
require "./config.rb"

if __FILE__ == $0
    
    current_speed_level = ""
    current_temp = 0.0

               

    t = TempMon.new
    temps = t.readSensors()
    current_temp = temps[Config::SensorKey].to_f

    fc = FanControl.new

    g = Graphite.new(Config::Graphite)
    s = Statsd.new(Config::Statsd)

    triggers = [ g , s ]




    if current_temp > Config::TooHot
        current_speed_level = "high"
    elsif current_temp < Config::TooCool
        current_speed_level = "low"
    else
        current_speed_level = "medium"
    end

    fc.setFanSpeed(current_speed_level)

    current_speed = fc.getCurrent().strip!

    triggers.each { |t|
        t.trigger("#{Config::MetricKey}.fan.#{current_speed_level}", 1)
        t.trigger("#{Config::MetricKey}.#{Config::SensorKey}", current_temp)
        t.trigger("#{Config::MetricKey}.fan.speed", current_speed)
    }

    s = Sensors.new
    ss = s.report()
    ss.each { |k, v|
        triggers.each { |t|
            t.trigger("#{Config::MetricKey}.#{k}", v)
        }
    }

end
