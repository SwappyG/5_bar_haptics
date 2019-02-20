%% 826 Test Code

%% 826 Initialize

% Declare Constants for path and board
HDR_PATH = 'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\826api.h';               % Path to API header
DLL_PATH = 'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\x64\s826.dll';     % Path to API executable
BOARD_NUM = 0;                                                          % Use 826 board #0 (i.e., board ID switches set to 0)

% Load the API
[errcode, boardflags] = s826.SystemOpen(DLL_PATH, HDR_PATH);              % Load the API, open it and get flags that indicate detected 826 boards

% Check for errors with loading API
if (errcode ~= s826.ERR_OK)                                             % If API failed to open
    disp(errcode)
    error("S826_SystemOpen failed");                                    %   Abort
end

% Check if the board is detected
if (bitand(uint32(boardflags), bitshift(uint32(1), BOARD_NUM)) == 0)    %   If specified board wasn't detected
    error("Board not detected");                                     %     Report error (check board's switch settings)
end

%% Run the Main Processes

% % Get DAC Range
% [errcode, range, setpoint] = DacRead(board, chan, safemode);

% Set the range of a DAC Pin
errcode = s826.DacRangeWrite(BOARD_NUM, 0, s826.DAC_SPAN_10_10, s826.BANKSEL_RUNMODE);

while(1)
    request = input('input 16 bit number, or -11 to quit');
    if request == -11
        'quitting' %#ok<NOPTS>
        break
    end
    
    % Write analog value to a DAC Pin
%     errcode = s826.DacDataWrite(BOARD_NUM, 0, request, s826.BANKSEL_RUNMODE)
    s826_custom.SetDacOutput(0, 0, s826.DAC_SPAN_10_10, request)
end 


%% Close and unload the API
s826.SystemClose();                                                 % Close and unload the API
