function velocity = calc_velocity(positions, tstamps, C)

    % NOTE, C is a struct containing all constants
    
    velocity = zeros(size(C.MOTORS,1), 3);
    
    % Iterate through both arms
    for i = 1:size(C.MOTORS,1)
        
        % find the average delta between tstamps for each joint
            % Perhaps theres a better way to determine this quantity
        t_delta_avg = mean(tstamps(C.CURR, i, :) - tstamps(C.PREV, i, :));
        
        % Calc velocity as delta_pos/delta_time
        velocity(i) = ( positions(C.CURR, i) - positions(C.PREV, i) ) / ...
                      ( t_delta_avg );
        
                  
        velocity(i, :) = ( positions(C.CURR, i, :) - positions(C.PREV, i, :) ) / ( t_delta_avg );
    end

end