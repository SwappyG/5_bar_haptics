function initialize_counters(s826_obj, this_arm, reset_on_rising_edge)
    
    board = this_arm.board_num;
    enc_ids = this_arm.enc_ids;
    enc_zero_cnt = this_arm.enc_zero_cnt;
    
    % Iterate through both arms
    for i = 1:length(enc_ids)
        
        if reset_on_rising_edge
            % Set the counter to QUADx4 and reset enc on IX Rising edge
            s826_obj.CounterModeWrite(board, enc_ids(i), bitor(s826_obj.CM_K_QUADX4, s826_obj.CM_PX_IXRISE));
        else
            % Set the counter to QUADx4 only
            s826_obj.CounterModeWrite(board, enc_ids(i), s826_obj.CM_K_QUADX4);
        end
        
        % Set the counter to enc_zero_cts on index rising edge
        s826_obj.CounterPreloadWrite(board, enc_ids(i), 0, enc_zero_cnt(i));

        % Enable the snapshot function
        s826_obj.CounterStateWrite(board, enc_ids(i), 1);

    end
    
end
