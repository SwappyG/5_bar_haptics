%% 826 Initialize

% clear all
close all

% add subfolders to the current path
addpath('./classes');
addpath('./constants');
addpath('./functions_application');
addpath('./functions_data_acq');
addpath('./functions_firmware');

% import the API
import s826.*
import s826_custom.*
import arm.*

% load the constants into the workspace
constants

% create an instance of the s826 class (API for Sensoray 826 card)
s826_obj = s826();

arms(1) = arm( C('ARM_1') );
arms(2) = arm( C('ARM_2') );
          
% initialize the API
[API_load_err, board_flags] = initialize_API(s826_obj, ...
                                             C('DLL_PATH'), ...
                                             C('HDR_PATH'), ...
                                             C('BOARD_NUM'));

% TO DO
    % Handle API_load_err and board_flag errs here
                                     
% Initialize the encoder counters
initialize_counters(s826_obj, arms(1).board_num, arms(1).enc_ids);
initialize_counters(s826_obj, arms(2).board_num, arms(2).enc_ids);

% Initialize the history buffers
init_hist_buffers(s826_obj, arms(1))
init_hist_buffers(s826_obj, arms(2))

% Set the loop rate
r = robotics.Rate(C('LOOP_RATE'));

% Send an initial zero                
send_voltage_cmds(s826_obj, arms(1), [0 0 0]);

mode = 'step'; % 'step' 'read_data' 'sin_wave' 'tri_wave' 'sq_wave'
id_to_test = 1;

% TO DO
    % Figure out how to home/reset encoders

%% Main Routine

tic
change_time = toc;

amp = 0;
freq = 100;
shift = freq/4;

r = robotics.Rate(400);

% Loop
while (toc < 10)
  
    % Read encoders and update new angles / time stamps
    get_angles(s826_obj, arms(1), true);

    switch mode
        
        case 'step'
                               
            % Send out steps to arm 1
            arms(1).ref_hist(arms(1).buffer_index, :) = generate_step(toc, ... 
                                                                      freq, ...
                                                                      -.4, ...
                                                                      .4, ...
                                                                      id_to_test);

            % Run controller
            [cmd_1, ~] = run_controller(arms(1), true); 
            arms(1).cmd_hist(arms(1).buffer_index, :) = cmd_1;
            
            % Send the voltage cmds to the servo controller through the 826
            send_voltage_cmds(s826_obj, arms(1), cmd_1);
            
        case 'read_data'
            
            disp([arms(1).angles]);
            
        case 'sin_wave'
            
            % Change the amplitude and frequency every so often
            if toc > change_time + 3 / freq
                change_time = toc;
                shift = toc;
                amp = rand()+1;
                freq = rand()+1.5;
            end
            
            % Generate next command
            cmd_voltages = [0 0 0];
            cmd_voltages(id_to_test) = amp*cos( (toc - shift) * freq * (2*pi) );
            
            % Store the command
            arms(1).cmd_hist(arms(1).buffer_index, :) = cmd_voltages;
            
            % Send the voltage cmds to the servo controller through the 826
            send_voltage_cmds(s826_obj, arms(1), cmd_voltages); 
            
        case 'tri_wave'
            
            % Change the amplitude and frequency every so often
            if toc > change_time + 3 / freq
                change_time = toc;
                shift = toc;
                amp = 1*rand()+1;
                freq = rand()+1;
            end
            
            % Generate next command
            cmd_voltages = [0 0 0];
            cmd_voltages(id_to_test) = amp*sawtooth((toc-shift)*(2*pi)*freq, 0.5);
            
            % Store the command
            arms(1).cmd_hist(arms(1).buffer_index, :) = cmd_voltages;
            
            % Send the voltage cmds to the servo controller through the 826
            send_voltage_cmds(s826_obj, arms(1), cmd_voltages); 
        
        case 'sq_wave'
            
            % Change the amplitude and frequency every so often
            if toc > change_time + 3 / freq
                change_time = toc;
                
                amp = .5*rand()+.5;
                freq = 1*rand()+1;
                shift = toc + 1/freq/4;
            end
            
            % Generate next command
            cmd_voltages = [0 0 0];
            cmd_voltages(id_to_test) = amp*square((toc-shift)*(2*pi)*freq);
            
            % Store the command
            arms(1).cmd_hist(arms(1).buffer_index, :) = cmd_voltages;
            
            % Send the voltage cmds to the servo controller through the 826
            send_voltage_cmds(s826_obj, arms(1), cmd_voltages);  
            
    end
       
    % Loop at set frequency
    waitfor(r);
    
end

% Send a 0 before end
send_voltage_cmds(s826_obj, arms(1), [0 0 0]);

% Plot the results
switch mode
  
    case 'step'
        plot_step(arms(1), ...
                  -.4, ...
                  .4, ...
                  id_to_test, ...
                  1)
        
    case 'sin_wave'
        figure(1)
        hold on
        plot(arms(1).time_hist(:,id_to_test), arms(1).ang_hist(:,id_to_test));
        plot(arms(1).time_hist(:,id_to_test), arms(1).cmd_hist(:,id_to_test));
        hold off
    
    case 'tri_wave'
        figure(1)
        hold on
        plot(arms(1).time_hist(:,id_to_test), arms(1).ang_hist(:,id_to_test));
        plot(arms(1).time_hist(:,id_to_test), arms(1).cmd_hist(:,id_to_test));
        hold off
        
    case 'sq_wave'
        figure(1)
        hold on
        plot(arms(1).time_hist(:,id_to_test), arms(1).ang_hist(:,id_to_test));
        plot(arms(1).time_hist(:,id_to_test), arms(1).cmd_hist(:,id_to_test));
        hold off
        
end

% Create a dataset object of this run
dataset = iddata(arms(1).ang_hist(:,id_to_test), arms(1).cmd_hist(:,id_to_test), 0.01);
