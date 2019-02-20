%*********************************************************************************************
% File         : s826_demo.m
% Function     : Simple Matlab example for Sensoray 826 PCIe multifunction board
% Dependencies : 826 device driver must be installed.
%                826 API (s826.dll) and header (826api.h) must be located in specified paths.
%                Matlab project consists of this file and 826 support class (s826.m).
% Author       : Jim Lamberson
% Copyright    : (C) 2018 Sensoray
%
% This program is free software: you can redistribute it and/or modify   
% it under the terms of the GNU General Public License as published by   
% the Free Software Foundation, version 3. 
% 
% This program is distributed in the hope that it will be useful, but  
% WITHOUT ANY WARRANTY; without even the implied warranty of  
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU  
% General Public License for more details. 
% 
% You should have received a copy of the GNU General Public License  
% along with this program. If not, see <http://www.gnu.org/licenses/>.
%*********************************************************************************************

% Change these values as required:
hdrPath = 'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\826api.h';               % Path to API header
dllPath = 'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\x64\s826.dll';     % Path to API executable
board = 0;                                                          % Use 826 board #0 (i.e., board ID switches set to 0)

[errcode, boardflags] = s826.SystemOpen(dllPath, hdrPath);              % Load the API, open it and get flags that indicate detected 826 boards
if (errcode ~= s826.ERR_OK)                                             % If API failed to open
    error("S826_SystemOpen failed");                                    %   Abort
else                                                                    % Else
    if (bitand(uint32(boardflags), bitshift(uint32(1), board)) == 0)    %   If specified board wasn't detected
        disp("Board not detected");                                     %     Report error (check board's switch settings)
    else                                                                %   Else
        MainProcess(board);                                             %     Call some API functions to interact with the hardware
    end
    s826.SystemClose();                                                 % Close and unload the API
end


function MainProcess(board)  % Demonstrate how to call 826 API functions

    fprintf('\nSENSORAY 826 EXAMPLES\n\n');
    
    % These examples check for and report errors -----------------------------------
    
    % DIO demo
    errcode = s826.DioOutputWrite(board, [6 0], s826.BITWRITE);    % Turn on DIO3 and DIO2; turn off all other DIOs
    if (errcode ~= s826.ERR_OK)
        disp(["Error: S826_DioInputRead() returned " num2str(errcode)]);
    end

    [errcode, data] = s826.DioInputRead(board);                         % Read DIO pin states
    if (errcode ~= s826.ERR_OK)
        disp(["Error: S826_DioInputRead() returned " num2str(errcode)]);
    end
    fprintf('DIO pin states:');
    disp(data);  % display DIO states
    
    % These examples omit error checking for clarity --------------------------------
    
    % Note: Production-quality code should always check for and handle errors. 
   
    % Counter demo
    fprintf('Periodic timer demo: ');
    CreatePeriodicTimer(board, 0);          % Configure counter as periodic timer.
    StartPeriodicTimer(board, 0, 500000);   % Set timer interval to 0.5 seconds and start it running.
    for i = 1:10                            % Process 10 timer ticks: 
        WaitForPeriodicTimer(board, 0);     %   Wait for next timer interrupt.
        fprintf('%d ', i);                  %   Display tick count.
    end
    StopPeriodicTimer(board, 0);            % Stop timer.
    fprintf('\n\n');
    
    % DAC demo
    fprintf('Ramping DAC0 from -10 to +10 V ... ');
    s826.DacRangeWrite(board, 0, s826.DAC_SPAN_10_10, s826.BANKSEL_RUNMODE); % Set DAC0 output range to +/-10V.
    for i = 0:65535
        s826.DacDataWrite(board, 0, i, s826.BANKSEL_RUNMODE);                % Ramp DAC0 voltage.
    end
    s826.DacDataWrite(board, 0, 50000, s826.BANKSEL_RUNMODE);                % Set DAC0 voltage to 0 V.
    fprintf('done\n\n');
    
    % ADC demo
    fprintf('Show samples from analog input 0 ... ');    
    StartAdc(board, 0);                     % Configure adc and trigger generator (counter0) and start them running.
    for i = 0:10                            % Repeat 10 times:
        [~, data] = ReadAdc(board);         %   Wait for next adc sample.
        disp(data);                         %   Display sample.
    end
    StopAdc(board, 0);                      % Halt trigger generator and adc.
    
end

% Utility functions ===========================================================

% The following code is adapted from C examples on Sensoray's Technical Support Wiki

% Use counter to pace software ------------------------------

% Configure counter as a periodic timer.
function [errcode] = CreatePeriodicTimer(board, chan)
    s826.CounterStateWrite(board, chan, 0);             % Disable counter.
    s826.CounterModeWrite(board, chan, ...              % Configure counter mode:
        s826.CM_K_1MHZ ...                              %   clock source = 1 MHz internal
        + s826.CM_PX_START + s826.CM_PX_ZERO ...        %   preload @start and counts==0
        + s826.CM_UD_REVERSE);                          %   count down
    errcode = s826.CounterSnapshotConfigWrite(board, chan, s826.SSRMASK_ZERO, s826.BITWRITE);   % Snapshot upon counts->0.
end

% Start periodic timer.
function [errcode] = StartPeriodicTimer(board, chan, period)
    s826.CounterPreloadWrite(board, chan, 0, period);   % Set timer interval (microseconds).
    errcode = s826.CounterStateWrite(board, chan, 1);   % Start timer.
end

% Stop periodic timer.
function [errcode] = StopPeriodicTimer(board, chan)
    errcode = s826.CounterStateWrite(board, chan, 0);   % Stop timer.
end

% Wait for next periodic timer tick.
function errcode = WaitForPeriodicTimer(board, chan)
    errcode = s826.CounterSnapshotRead(board, chan, s826.WAIT_INFINITE);  % Block until next timer tick. Ignore snapshot values.
end

% Measure analog input 0 ------------------------------

function [errcode] = StartAdc(board, ctr)

    period = 250000;    % Perform an A/D conversion every 0.25 seconds.
    
    % Configure ADC.
    s826.AdcSlotConfigWrite(board, 0, ...               % Config timeslot0:
        0, ...                                          %   Digitize analog input 0.
        20, ...                                         %   After switching input, settle 20 us before converting.
        s826.ADC_GAIN_1);                               %   Use -10 to +10 V measurement range.
    s826.AdcSlotlistWrite(board, 1, s826.BITWRITE);     % Enable timeslot0; all others are disabled.
    s826.AdcTrigModeWrite(board, ...                    % Configure ADC triggering:
        s826.ADC_TRIGENABLE + s826.ADC_TRIGFALLING ...  %   Trigger on falling edge
        + s826.INSRC_EXTOUT(0));                        %    of counter0 ExtOut signal.

    % Configure counter as periodic pulse generator; every output pulse will trigger one ADC burst.
    s826.CounterModeWrite(board, ctr, ...               % Configure counter0 mode:
        s826.CM_K_1MHZ ...                              %   clock source = 1 MHz internal
        + s826.CM_PX_START + s826.CM_PX_ZERO ...        %   preload @start and counts==0
        + s826.CM_UD_REVERSE ...                        %   count down
        + s826.CM_OM_NOTZERO);                          %   ExtOut = (counts!=0)
    s826.CounterPreloadWrite(board, ctr, 0, period);    % Set period in microseconds.
    
    % Start A/D conversions.
    s826.AdcEnableWrite(board, 1);                      % Enable ADC conversions.
    errcode = s826.CounterStateWrite(board, ctr, 1);    % Start trigger generator.
end

function [errcode] = StopAdc(board, ctr)
    s826.CounterStateWrite(board, ctr, 0);              % Halt trigger generator.
    errcode = s826.AdcEnableWrite(0, 0);                % Disable ADC conversions.
end

function [errcode, data] = ReadAdc(board)
    [errcode, adcdata, ~, ~] = s826.AdcRead(board, 1, s826.WAIT_INFINITE);  % Wait for next timeslot0 sample to become available.
    data = adcdata(1);                                                      % Return timeslot0 data (using Matlab's 1-based array index).
end
