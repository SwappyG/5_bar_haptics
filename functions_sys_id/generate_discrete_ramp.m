function cmd_volt = generate_discrete_ramp(curr_time, period, incr, low, high, channel)

    cmd_volt = [0 0 0];
    
    steps = floor(curr_time/period);
    cmd_volt(channel) = steps*incr + low;
    if high < low
        cmd_volt(channel) = max(high, cmd_volt(channel));
    else
        cmd_volt(channel) = min(high, cmd_volt(channel));
    end
    
end
