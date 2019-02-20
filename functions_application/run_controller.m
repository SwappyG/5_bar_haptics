function [cmd, cumm_err] = run_controller(this_arm, update)
    
    % Grab the current and previous index
    curr_index = this_arm.buffer_index;
    prev_index = curr_index - 1;
    
    % Handle edge case
    if prev_index < 1
        prev_index = this_arm.hist_depth;
    end
    
    % Get the delta time for each joint
    dt = clip(this_arm.time_hist(curr_index,:) - this_arm.time_hist(prev_index,:), 0, 0.2);
    Kp = this_arm.Kp;
    Kd = this_arm.Kd;
    Ki = this_arm.Ki;
    tol = this_arm.tol;
    
    if this_arm.ctrl_mode == "pid"
    
        % Get current and prev error
        err = this_arm.ref_hist(curr_index,:) - this_arm.ang_hist(curr_index, :);
        prev_err = this_arm.ref_hist(prev_index,:) - this_arm.ang_hist(prev_index,:);
    
        err_for_ki = err;
        err_for_ki( abs(err_for_ki) < tol ) = 0;
        
        % add err to the accumulator, return to calling script
        cumm_err = this_arm.cumm_err + err_for_ki.*dt;

        % calculate the pid controller output
        cmd = err.*Kp + (err-prev_err)./dt.*Kd + cumm_err.*Ki;
        
        % Only update the cumulative error if the update flag is set
        if update
            this_arm.cumm_err = cumm_err;
        end
    
    % Other control modes, not implemented
    elseif this_arm.ctrl_mode == "ss"
        
        error('State Space control is not implemented yet');
    
    else
        error('Invalid ctrl mode');
    end
    
    
    
    
    
end