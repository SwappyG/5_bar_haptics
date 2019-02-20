function [errcode, boardflags] = initialize_API(s826_obj, DLL_PATH, HDR_PATH, BOARD_NUM)
    
    % Load the API
    try 
        [errcode, boardflags] = s826_obj.SystemOpen(DLL_PATH, HDR_PATH);              % Load the API, open it and get flags that indicate detected 826 boards
    catch SysOpenErr
        try %#ok<TRYNC>
            s826.SystemClose();
        end
        error('Failed to load the API, check the HDR_PATH and DLL_PATH constants and ensure they are accurate')
    end

    % Check for errors with loading API
    if (errcode ~= s826_obj.ERR_OK)                                             % If API failed to open
        disp(errcode)
        error("S826_SystemOpen failed");                                    %   Abort
    end

    % Check if the board is detected
    if (bitand(uint32(boardflags), bitshift(uint32(1), BOARD_NUM)) == 0)    %   If specified board wasn't detected
        error("Board not detected");                                     %     Report error (check board's switch settings)
    end
    
end