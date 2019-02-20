function err = send_voltage_cmds(s826_obj, this_arm, cmds)

    % NOTE, C is a struct containing all constants
    
    err = zeros(length(cmds), 1);
    
    % TO DO:
        % Add feedback from limit switches to prevent unnecessary commands
        % when the limit switches are tripped
    
    % TO DO:
        % Add software limits to prevent commands when outside software
        % limit bounds to reduce taxing the limit switches and hardstops
        
    % Iterate through both arms
    for i = 1:length(this_arm.motor_ids)
           
        % Saturate the command to be within limits
            % This is a safety from firmware end, not controller end
            % e.g, if its determined that the turntable of arm 1 should
            % never spin faster than some threshold, that should be
            % reflected in the values of MAX_VOLT and MIN_VOLT. This
            % way, if a controller is ever designed such that it
            % demands an output outside this bound, itll be clipped
            % here at the 'firmware' level. The controller designer can
            % also opt to use their own saturator block in the
            % controller and should NOT modify these values. 
        cmd_v = min(this_arm.max_volt(i), max(this_arm.min_volt(i), cmds(i)));

        % Send the cmd out through the 826
        err(i) = s826_custom.SetDacOutput(   this_arm.board_num, ...
                                             this_arm.motor_ids(i), ...
                                             s826_obj.DAC_SPAN_10_10, ...
                                             cmd_v);
       
      
        
    end
    
end
