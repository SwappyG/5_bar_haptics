function velocities = calc_velocities(positions, tstamps, motors, curr, prev)

    velocities = zeros(size(motors,1));
    
    for i = size(motors,1)
        velocities(i) = (positions(curr, i) - positions(prev, i)) / (mean(tstamps(curr, i, :)) - mean(tstamps(prev, i, :)));
    end


end