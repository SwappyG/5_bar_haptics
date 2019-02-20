classdef arm < handle
    
    properties
       
        link_lens = [];
        
        num_motors = 3;
        board_num = 0;
        
        motor_ids = [];
        enc_ids = [];
        
        ang_hist = [];
        time_hist = [];
        cmd_hist = [];
        ref_hist = [];
        
        buffer_index = 0;
        hist_depth = 1;
        init_tstamp = [0 0 0];
        filter_const = [0.0001 0.0001 0.0001];
        tstamp_factor = 1e-6;
        overflow_count = 0;
        max_t = bin2dec('1111 1111 1111 1111 1111 1111 1111 1111');
        
        max_angs = [];
        min_angs = [];
        
        max_volt = [10 10 10];
        min_volt = [-10 -10 -10];
        
        enc_cnt_per_rev = 4*65535;
        enc_rad_per_cnt = 2*pi/4/65535;
        enc_zero_cnt = [];
        
        ref_angles = [0 0 0];
        
        cumm_err = [0 0 0];
        Kp = 0;
        Kd = 0;
        Ki = 0;
        tol = 0.01;
        K1 = [];
        K2 = [];
        ctrl_mode = 'pid';
        
        A = [];
        B = [];
        C = [];
        D = []; 
        
        
    end

    methods
       
        function obj = arm(init_data) % mot_ids, enc_ids, link_lens, max_angs, ...
                            % min_angs, enc_zero_cnt, enc_cnt_per_rev)
            
            % parse arguments
            mot_ids =           init_data('MOTOR_IDS');
            enc_ids =           init_data('ENC_IDS');
            link_lens =         init_data('LENS');
            max_angs =          init_data('MAX_ANG');
            min_angs =          init_data('MIN_ANG');
            enc_zero_cnt =      init_data('ENC_ZERO_CNT');
            enc_cnt_per_rev =   init_data('ENC_CTS_PER_REV');
            kp =                init_data('KP');
            kd =                init_data('KD');
            ki =                init_data('KI');
            ctrl_mode =         init_data('CTRL_MODE');
            hist_depth =        init_data('HIST_DEPTH');
            filter_const =      init_data('FILTER_CONST');
            max_t =             init_data('MAX_T');
            tol =               init_data('TOL');
            
            % Motor IDs --
            if length(mot_ids) == 3
                obj.motor_ids = mot_ids;
            else
                obj.motor_ids = [];
                warning('Motors IDs must be a 3 element array');
            end
            % --

            % Enc IDs --
            if length(enc_ids) == 3
                obj.enc_ids = enc_ids;
            else
                obj.enc_ids = [];
                warning('Enc IDs must be a 3 element array');
            end
            % --

            % Link Lengths -- 
            if length(link_lens) == 5
                obj.link_lens = link_lens;
            else
                obj.link_lens = [];
                warning('Link Length must be a 5 element array');
            end

            % max_angs -
            if length(max_angs) == 3
                obj.max_angs = max_angs;
            else
                obj.max_angs = [];
                warning('Max Angles must be a 3 element array');
            end
            % --

            % min angs
            if length(mot_ids) == 3
                obj.min_angs = min_angs;
            else
                obj.min_angs = [];
                warning('Min Angles must be a 3 element array');
            end
            % --

            % Encoder zero count --
            if length(enc_zero_cnt) == 3 && all(enc_zero_cnt > 0)
                obj.enc_zero_cnt = enc_zero_cnt;
            else
                obj.enc_zero_cnt = 100000;
                warning('Enc Zero Cnt must have len 3, and all elements > 0');
            end
            % --

            % Encoder Count Per Rev
            obj.enc_cnt_per_rev = enc_cnt_per_rev;
            obj.enc_rad_per_cnt = 2*pi./obj.enc_cnt_per_rev;
            % --
            
            % Kp, Kd, Ki --
            obj.Kp = kp;
            obj.Kd = kd;
            obj.Ki = ki;
            obj.ctrl_mode = ctrl_mode;
            obj.cumm_err = [0 0 0];
            % --
            
            % history array sizes
            obj.ang_hist = NaN(hist_depth, 3);
            obj.time_hist = NaN(hist_depth, 3);
            obj.cmd_hist = NaN(hist_depth, 3);
            obj.ref_hist = NaN(hist_depth, 3);
            obj.hist_depth = hist_depth;
            % --
            
            % filtering
            obj.filter_const = filter_const;
            obj.max_t = max_t;
            obj.tol = tol;
            
        end
        
    end
    
end