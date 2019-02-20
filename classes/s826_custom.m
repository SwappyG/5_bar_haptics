%% Custom Class to add functionality on top of s826 API from Sensoray
% It inherits all properties / methods from the s826 class

classdef s826_custom < s826
    
    % New constants
    properties (Constant = true)
        
    end
    
    % New Methods
    methods (Static)
        
        % Sets the output of a given DAC channel with argument in volts
        function errcode = SetDacOutput(board, chan, range, volts)
            switch range
                case s826.DAC_SPAN_0_5
                    setpoint = round(volts * 65535 /  5);
                case s826.DAC_SPAN_0_10
                    setpoint = round(volts * 65535 / 10); 
                case s826.DAC_SPAN_5_5
                    setpoint = round(volts * 65535 / 10) + 32768;
                case s826.DAC_SPAN_10_10
                    setpoint = round(volts * 65535 / 20) + 32768;
            end      
            errcode = s826.DacDataWrite(board, chan, setpoint, 0);
        end
        
        
        
        
        
    end
    
end      
        
