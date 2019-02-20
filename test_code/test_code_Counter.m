%% 826 Test Code

%% 826 Initialize

% Declare Constants for path and board
HDR_PATH = 'C:\Users\agomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\826api.h';               % Path to API header
DLL_PATH = 'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\x64\s826.dll';     % Path to API executable
BOARD_NUM = 0;                                                          % Use 826 board #0 (i.e., board ID switches set to 0)

% Load the API
try 
    [errcode, boardflags] = s826.SystemOpen(DLL_PATH, HDR_PATH);              % Load the API, open it and get flags that indicate detected 826 boards
catch SysOpenErr
    try %#ok<TRYNC>
        s826.SystemClose();
    end
    error('Failed to load the API, check the HDR_PATH and DLL_PATH constants and ensure they are accurate')
end

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

errcode = s826.CounterModeWrite(BOARD_NUM, 0, s826.CM_K_QUADX4);
errcode = s826.CounterStateWrite(BOARD_NUM, 0, 1);

while 1
    
    [errcode, counts] = s826.CounterRead(BOARD_NUM, 0);
    
    disp(counts);
end



%% Close and unload the API
s826.SystemClose();                                                 % Close and unload the API
