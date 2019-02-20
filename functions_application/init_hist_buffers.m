function init_hist_buffers(s826_obj, this_arm)

    % Read values from the encoders to make sure any garbage data is flushed
    for index = 1:4
        get_angles(s826_obj, this_arm, false);
    end 

    err = true;
    
    % Read some data from the encoders and initialize the buffers
    while err == true
        [err, ang, tstamp] = get_angles(s826_obj, this_arm, false);
    end
    
    this_arm.init_tstamp = tstamp;
    this_arm.ang_hist(1, :) = ang;
    this_arm.ref_hist(1, :) = ang;
    this_arm.time_hist(1, :) = [0 0 0];

    % Read some more data, pad the buffers a bit
    for index = 2:10
        
        err = true;
        
        while err == true
            [err, ang, tstamp] = get_angles(s826_obj, this_arm, false);
        end
        
        this_arm.ang_hist(index, :) = ang;
        this_arm.ref_hist(index, :) = ang;
        this_arm.time_hist(index, :) = tstamp;
        
    end

    % Initialize the cmd_hist for the first few indices
    this_arm.cmd_hist(1:10, :) = repmat([0 0 0], 10, 1);

    % Set the buffer index to end of padded data
    this_arm.buffer_index = 10;


end