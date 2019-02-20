function initialize_DAC(s826_obj, this_arm)
    
    board = this_arm.board_num;
    motor_ids = this_arm.motor_ids;
    
    % Iterate through both arms
    for i = 1:length(motor_ids)
       
        % set DAC to normal mode with range +/- 10V
        s826_obj.DacRangeWrite(board, motor_ids(i), s826_obj.DAC_SPAN_10_10, s826_obj.BANKSEL_RUNMODE);    

    end
    
end
