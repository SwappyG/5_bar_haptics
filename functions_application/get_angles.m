function [err, angles, tstamps] = get_angles(s826_obj, this_arm, update)

    % NOTE, C is a struct containing all constants

    % Create empty arrays to accept the values
    angles = zeros(1, length(this_arm.enc_ids));
    tstamps = zeros(1, length(this_arm.enc_ids));
    buffer_index = this_arm.buffer_index;
    hist_depth = this_arm.hist_depth;
    
    err = false;
    
    % Iterate through all joints in arm
    for i = 1:length(this_arm.enc_ids)

        % Read the encoder and record the angle / tstamp
        s826_obj.CounterSnapshot(this_arm.board_num, this_arm.enc_ids(i));
        
        [~,enc,t_raw,~] = s826_obj.CounterSnapshotRead( this_arm.board_num, ...
                                                        this_arm.enc_ids(i), ... 
                                                        0);
        
        % if bad data is detected, set err to true and return all NaN's
        if enc == 0 || t_raw == 0 || isnan(enc) || isinf(enc) || isnan(t_raw) || isinf(t_raw)
            err = true;
            angles = [NaN NaN NaN];
            tstamps = [NaN NaN NaN];
            return
        end
                                                    
        % Adjust the tstamp to appropriate units
        tstamps(i) = double(t_raw) * this_arm.tstamp_factor - this_arm.init_tstamp(i);

        % Adjust the encoder counts to appropriate angles
        angles(i) = (double(enc) - this_arm.enc_zero_cnt(i)) * this_arm.enc_rad_per_cnt(i); 

        % Clip the angle to be within max/min range
        if angles(i) > this_arm.max_angs(i)
            angles(i) = this_arm.max_angs(i);
        elseif angles(i) < this_arm.min_angs(i)
            angles(i) = this_arm.min_angs(i);
        end
            
        
    end
    
    % Update history buffers if flag is set
    if update 
        
        % Grab the previous time and angles
        last_time = this_arm.time_hist(buffer_index, :);
        last_ang = this_arm.ang_hist(buffer_index, :);
        
        % grab the max time in seconds before overflow
        max_t = this_arm.max_t;
        
        % get the overflow counter
        overflow_count = this_arm.overflow_count;
        
        % Move to next index
        buffer_index = buffer_index + 1;

        % Wrap around if necessary
        if buffer_index > hist_depth
            buffer_index = 1;
        end
        
        % if the current time stamp < previous, increment overflow counter
        if tstamps(1) + max_t*overflow_count < last_time
            this_arm.overflow_count = overflow_count + 1;
        end
        
        % set the current time as 
        this_arm.time_hist(buffer_index, :) = tstamps + max_t*this_arm.overflow_count;
        
        % Calculate the time delta since last update
        dt = this_arm.time_hist(buffer_index, :) - last_time;
        
        % Calculate the decay constant
        alpha = 1 - exp(-dt/this_arm.filter_const);
        
        % get the new angle as an exponential weighting of all history
        this_arm.ang_hist(buffer_index, :) = last_ang.*(1-alpha) + angles.*alpha;
        
        % update the buffer index
        this_arm.buffer_index = buffer_index;
    end
    
    
    
    
end