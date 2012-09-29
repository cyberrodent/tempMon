


class Config

    TooHot  = 47
    TooCool = 42.5

    SensorKey = "temp2_input"

    MetricKey = "macmini.sensors"

    Statsd = {
        :host =>  "192.168.1.200",
        :port => 8125
    }

    Graphite = {
        :host => "192.168.1.200",
        :port => 2003
    }

end
