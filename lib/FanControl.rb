class FanControl

    SpeedLevels = {
        "low" => 3200,
        "medium" => 4200,
        "high" => 5100
    }

    Device_Path = "/sys/devices/platform/applesmc.768"

    def setFanSpeed(level)
        # should check that level is in SpeedLevels
        speed_settings = SpeedLevels[level]
        `echo 1 > #{Device_Path}/fan1_manual`
        `echo #{speed_settings} > #{Device_Path}/fan1_output`
    end

    def getCurrent()
        `cat #{Device_Path}/fan1_output`
    end
end
