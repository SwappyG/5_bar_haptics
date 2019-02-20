function ang_velos = calc_ang_velos(angles, tstamps, C)

    % NOTE, C is a struct containing all constants
    
    % Declare empty array to hold data
    ang_velos = zeros(size(C.MOTORS,1), size(C.MOTORS,2));
    
    % Iterate through both arms
    for i = 1:size(C.MOTORS,1)
        
        % Iterate through all joints
        for j = 1:size(C.MOTORS,2)
            
            % Calculate the angular velocity
            ang_velos(i,j) = ( angles(C.CURR, i, j) - angles(C.PREV, i, j)) / ...
                                (tstamps(C.CURR, i, j) - tstamps(C.PREV, i, j) );
        end
    end


end