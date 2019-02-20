function positions = forward_kinematics(angles, C)

    % NOTE, C is a struct containing all constants
    
    positions = zeros(size(C.MOTORS,1), 3);
    
    % Iterate through both arms
    for i = 1:size(C.MOTORS,1)
       
        % Extract the constants to local variables for legibility
            % CAN BE BYPASSED TO IMPROVE SPEED IF NECESSARY
        theta_1 = angles(i,1);
        theta_2 = angles(i,2);
        theta_3 = angles(i,3);
        L1 = C.ARM_DIMS(i,1);
        L2 = C.ARM_DIMS(i,2);
        L3 = C.ARM_DIMS(i,3);
        L4 = C.ARM_DIMS(i,4);
        L5 = C.ARM_DIMS(i,5);
        
        
        
        % Find the position of the first and second links
        P1 = [L1 * sin(theta_1); L1 * cos(theta_1)];
        P2 = [-L2 * cos(theta_2); L2 * sin(theta_2)];

        % Find the distance between P1 and P2
        Lm = norm(P1-P2);

        % Find the angle opposite L3 in Triangle L3-L4-Lm
        phi_3 = acos( (L3^2 - L4^2 - Lm^2) / (-2*Lm*L4) );
        
        % Find the angle opposite L2 in Triangle L1-L2-Lm
        lamda_2 = acos( (L2^2 - L1^2 - Lm^2) / (-2*Lm*L1) );
        
        % Note that the enclosed angle between L1-L4 = phi_3 + lamda_2
        % L4 and L5 are co-linear
        
        % Find the angle between horizontal and L5
        theta_5 = pi/2 - theta_1 - phi_3 - lamda_2;
        
        P5 = [L5*cos(theta_5); L5*sin(theta_5)];
        
        % Find the position of the tip as vector sum of L1 + L5
        positions(i, 1) = ( P1(1) + P5(2) ) * cos(theta_3);
        positions(i, 2) = ( P1(1) + P5(2) ) * sin(theta_3);
        positions(i, 3) = P1(2) + P5(2);
        
        
    end



end
