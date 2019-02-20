function ref_angles = generate_step(curr_time, period, low, high, channel)

    ref_angles = [0 0 0];

    if mod(floor(curr_time/period), 2)
        ref_angles(channel) = low;
    else
        ref_angles(channel) = high;
    end

end