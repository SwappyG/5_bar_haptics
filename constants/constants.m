%% Constants

C = containers.Map;
ARM_1 = containers.Map;
ARM_2 = containers.Map;

% API Related Constants
C('HDR_PATH') =                'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\826api.h';               % Path to API header
C('DLL_PATH') =                'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\x64\s826.dll';     % Path to API executable
C('BOARD_NUM') =               0;

% Plotting constants - CURRENTLY UNUSED
C('ANIM_FIG_NUM') =             1;
C('ANIM_MAX_PTS') =             100;

% Arm Joint Enumeration
ARM_1('MOTOR_IDS') =            [1 3 2];
ARM_1('ENC_IDS') =              [1 0 2];
ARM_1('LENS') =                 [1 1 1 1 1];
ARM_1('MAX_ANG') =              [pi/2, pi/2, pi/2];
ARM_1('MIN_ANG') =              [-pi/2, -pi/2, -pi/2];
ARM_1('ENC_ZERO_CNT') =         100000 * [1 1 1];
ARM_1('ENC_CTS_PER_REV') =      4 * 65535 * [1 1 1];

ARM_2('MOTOR_IDS') =            [7 6 5];
ARM_2('ENC_IDS') =              [3 4 5];
ARM_2('LENS') =                 [1 1 1 1 1];
ARM_2('MAX_ANG') =              [pi/2, pi/2, pi/2];
ARM_2('MIN_ANG') =              [-pi/2, -pi/2, -pi/2];
ARM_2('ENC_ZERO_CNT') =         10000 * [1, 1, 1];
ARM_2('ENC_CTS_PER_REV') =      4 * 512 * [3 5/3 2];

% Time stamp
ARM_1('HIST_DEPTH') =           1000;
ARM_1('FILTER_CONST') =         [0.02 0.02 0.01];
ARM_1('MAX_T') =                bin2dec('1111 1111 1111 1111 1111 1111 1111 1111');

ARM_2('HIST_DEPTH') =           1000;
ARM_2('FILTER_CONST') =         [0.02 0.02 0.01];
ARM_2('MAX_T') =                bin2dec('1111 1111 1111 1111 1111 1111 1111 1111');

% Voltage Limits
ARM_1('MAX_VOLT') =             [10, 10, 10]; 
ARM_1('MIN_VOLT') =             [-10, -10, -10];

ARM_2('MAX_VOLT') =             [10, 10, 10]; 
ARM_2('MIN_VOLT') =             [-10, -10, -10];

% Feedback Control
ARM_1('KP') =                   [3, 6, 6];
ARM_1('KD') =                   [1.2, 1.5, 4];
ARM_1('KI') =                   [0, 0, 0];
ARM_1('TOL') =                  [0.01, 0.01, 0.01];
ARM_1('CTRL_MODE') =            'pid';

ARM_1('K_WIRE') =               0.4;
ARM_1('DEADZONE_MIN') =         0.1886;
ARM_1('DEADZONE_MAX') =         0.684;

ARM_2('KP') =                   [6, 3, 2];
ARM_2('KD') =                   [2, .5, 0];
ARM_2('KI') =                   [0, 0, 0];
ARM_2('TOL') =                  [0.01, 0.01, 0.01];
ARM_2('CTRL_MODE') =            'pid';

ARM_2('K_GRAVITY') =            0.7372;
ARM_2('K_SPRING') =             7;
ARM_2('SHLD_VERT_OFFSET') =     0.233;

% Main Loop params
C('LOOP_RATE') =                50;
C('MAX_RUN_TIME') =             600;

% Arm 2 encoder zeroing
C('ARM_2_ENC_LIMS') =           [11331 , 9347, 11528];

C('ARM_1') = ARM_1;
C('ARM_2') = ARM_2;








%% OBSOLETE

% C = struct;
% 
% % API Related Constants
% C.HDR_PATH = 'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\826api.h';               % Path to API header
% C.DLL_PATH = 'C:\Users\adgomes\Documents\5 Bar Haptics Project\sdk_826_win_3.3.9\s826_3.3.9\api\x64\s826.dll';     % Path to API executable
% C.BOARD_NUM = 0;
% 
% % Arm Joint Enumeration
% C.ARM1_MOTOR_IDS =          [1 3 2];
% C.ARM1_ENC_IDS =            [1 0 2];
% C.ARM1_LENS =               [1 1 1 1 1];
% C.ARM1_MAX =                [pi/4, pi/4, pi/4];
% C.ARM1_MIN =                [-pi/4, -pi/4, -pi/4];
% C.ARM1_ENC_ZERO_CNT =       100000 * [1 1 1];
% C.ARM1_ENC_CTS_PER_REV =    4 * 65535 * [1 1 1];
% 
% C.ARM2_MOTOR_IDS =          [4 5 6];
% C.ARM2_ENC_IDS =            [3 4 5];
% C.ARM2_LENS =               [1 1 1 1 1];
% C.ARM2_MAX =                [pi/4, pi/4, pi/4];
% C.ARM2_MIN =                [-pi/4, -pi/4, -pi/4];
% C.ARM2_ENC_ZERO_CNT =       100000 * [1 1 1];
% C.ARM2_ENC_CTS_PER_REV =    4 * 65535 * [1 1 1];
% 
% % Time stamp
% C.LEN_HISTORY = 1;
% C.TSTAMP_CONV_FACTOR = 1;
% C.CURR = 1;
% C.PREV = 2;
% 
% % Voltage Limits
% C.MAX_VOLT = [5, 5, 5; 
%               5, 5, 5];
% C.MIN_VOLT = [-5, -5, -5; 
%               -5, -5, -5];

