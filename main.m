%% Initializing the Script

clear all
close all

% add subfolders to the current path
addpath('./classes');
addpath('./constants');
addpath('./functions_application');
addpath('./functions_firmware');

% import the API
import s826.*
import s826_custom.*
import arm.*

% load the constants into the workspace
constants

arms(1) = arm( C('ARM_1') );
arms(2) = arm( C('ARM_2') );


%% Initializing the Hardware

% create an instance of the s826 class (API for Sensoray 826 card)
s826_obj = s826();

% initialize the API
[API_load_err, board_flags] = initialize_API(s826_obj, ...
                                             C('DLL_PATH'), ...
                                             C('HDR_PATH'), ...
                                             C('BOARD_NUM'));

% TO DO
    % Handle API_load_err and board_flag errs here

% Initialize the DACs
initialize_DAC(s826_obj, arms(1));
initialize_DAC(s826_obj, arms(2));
    
% Initialize the encoder counters
initialize_counters(s826_obj, arms(1), true);
initialize_counters(s826_obj, arms(2), false);

% Send an initial zero                
send_voltage_cmds(s826_obj, arms(1), [0 0 0]);


%% Zeroing the Arm

% Ask the user if they want to zero the arms, recommending to zero
user_input = questdlg("Would you like to zero the arms? If the PC was rebooted, THIS MUST BE DONE!!! If in doubt, click yes and zero the arms", ...
                      "Zeroing the arms", ...
                      "Yes", ...
                      "No", ...
                      "Yes" );

% If the user says yes, or closes the window (presumably without reading)
if user_input == "Yes" || user_input == ""
    
    % Run the zeroing routine
    err = run_zeroing_routine(s826_obj,arms(2),C('ARM_2_ENC_LIMS'));
    
    % If zeroing failed, throw error and exit
    if err
        send_voltage_cmds(s826_obj, arms(1), [0 0 0]);
        error('You must zero the arms before running, please restart');
    end
    
% If user says no, ask again to confirm, again, urging to zero it
else
    user_input = questdlg("Are you sure you don't want to zero the arm?" , ...
                          "Zeroing the Arm", ...
                          "No, Let's zero it", ...
                          "Yes, I'm certain", ...
                          "No, Let's zero it" );
    
    % If the user says let's zero it or closes the window
    if user_input == "No, Let's zero it" || user_input == ""
        
        % Run the zeroing routine
        err = run_zeroing_routine(s826_obj,arms(2),C('ARM_2_ENC_LIMS'));

        % If zeroing failed, throw error and exit
        if err
            send_voltage_cmds(s826_obj, arms(1), [0 0 0]);
            error('You must zero the arms before running, please restart');
        end
        
    else
        warning("The arms have not been zeroed as per user request")
    end
    
end


%% Initializing the main loop

% Initialize the history buffers
init_hist_buffers(s826_obj, arms(1))
init_hist_buffers(s826_obj, arms(2))

% Set the loop rate
r = robotics.Rate(C('LOOP_RATE'));



% Create handle for animated figure
exit_handle = uicontrol('Style', 'PushButton', ...
                        'String', 'Break', ...
                        'Callback', 'delete(gcbf)');


%% Main Routine

% Start the timer
tic

% loop until user closes figure with handle
while (ishandle(exit_handle))
     
    % Read encoders and update new angles / time stamps
    [err, ang_1, t_1] = get_angles(s826_obj, arms(1), true);
    if err
        warning('bad data encountered for arm 1, occasional bad data is normal');
        continue
    end
    
    [err, ang_2, t_2] = get_angles(s826_obj, arms(2), true);
    if err
        warning('bad data encountered for arm 2, occasional bad data is normal');
        continue
    end
 
    
    
    % Set the ref for arms as each others current val
    arms(1).ref_hist(arms(1).buffer_index, :) = ang_2;
    arms(2).ref_hist(arms(2).buffer_index, :) = ang_1;
    
    % Run the controller to get new commands
    [cmd_1, ~] = run_controller(arms(1), true);
    [cmd_2, ~] = run_controller(arms(2), true);
    
    % Add gravity non-lineary compensation to ARM_2 shoulder joint
    cmd_2(1) = cmd_2(1) - gravity_comp(ARM_2('SHLD_VERT_OFFSET') + ang_2(1), ...
                                       ARM_2('K_SPRING'), ...
                                       ARM_2('K_GRAVITY')   );
    
    % Add wire drag non-linearity compensation to ARM_1 turntable                             
    cmd_1(3) = cmd_1(3) + wire_drag_comp(ang_1(3), ...
                                         ARM_1('K_WIRE'), ...
                                         ARM_1('DEADZONE_MIN'), ...
                                         ARM_1('DEADZONE_MAX') );
                                   
                                   
    % Store the command in cmd_hist
    arms(1).cmd_hist(arms(1).buffer_index, :) = cmd_1;
    arms(2).cmd_hist(arms(2).buffer_index, :) = cmd_2;
    
    % if the system has just started, don't send cmds
    if (toc < 0.1)
        send_voltage_cmds(s826_obj, arms(1), [0 0 0]);
        send_voltage_cmds(s826_obj, arms(2), [0 0 0]);
        continue;
    end
    
    % If max time is exceeded, stop looping
    if (toc > C('MAX_RUN_TIME'))
        disp("---------")
        disp("---------")
        warning("Exceeded maximum run time, script shutting down")
        disp("---------")
        disp("---------")
        break
    end
    
    % Send the voltage cmds to the servo controller through the 826
    send_voltage_cmds(s826_obj, arms(1), cmd_1);
    send_voltage_cmds(s826_obj, arms(2), cmd_2);
    
    %Loop at set frequency
    waitfor(r);
end

% Send a zero voltage command upon exit
send_voltage_cmds(s826_obj, arms(1), [0 0 0]);
send_voltage_cmds(s826_obj, arms(2), [0 0 0]);






%% OBSOLETE

    %Draw the current pos and cmd voltages
%     for i = 1:3
%         addpoints(lines(1, i, 1), t_1(i), ang_1(i))
%         addpoints(lines(2, i, 1), t_2(i), ang_2(i))
%         
%         addpoints(lines(1, i, 2), t_1(i), cmd_1(i))
%         addpoints(lines(2, i, 2), t_2(i), cmd_2(i))
%     end
%     addpoints(loop_line, toc, r.LastPeriod)
%     drawnow


% Create handles for live data stream
% lines = create_animated_lines(C('ANIM_FIG_NUM'), C('ANIM_MAX_PTS'));
% subplot(5,1,5)
% loop_line = animatedline(gca, 'MaximumNumPoints',C('ANIM_MAX_PTS'));
                