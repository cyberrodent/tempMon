class Trigger
    @host = ''
    @port = ''
    def initialize(config)
        @host = config[:host]
        @port = config[:port]
    end

    def trigger(key, val)
        puts key, val
    end
end


