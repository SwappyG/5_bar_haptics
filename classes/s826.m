classdef s826
    
    %*************************************************************************
    % File         : s826.m
    % Function     : API wrapper for Sensoray 826 PCIe multifunction board.
    % Dependencies : 826 device driver must be installed.
    %                826 API (s826.dll) and header (826api.h) must be
    %                  located in paths specified to SystemOpen().
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
    %
    % Version log --------
    %   04/02/2018  Initial release.
    %*************************************************************************

    
    properties (Constant)  % Constants --------------
        
        % These Matlab "constants" have similar names to their underlying API constants.
        % For example, the API constant S826_ERR_OK is referenced in Matlab code as s826.ERR_OK

        
        % Error codes
        ERR_OK            = int32(0);         % No error
        ERR_BOARD         = int32(-1);        % Illegal board number
        ERR_VALUE         = int32(-2);        % Illegal argument value
        ERR_NOTREADY      = int32(-3);        % Device not ready or timeout waiting for device
        ERR_CANCELLED     = int32(-4);        % Wait cancelled
        ERR_DRIVER        = int32(-5);        % Driver call failed
        ERR_MISSEDTRIG    = int32(-6);        % Missed adc trigger
        ERR_DUPADDR       = int32(-9);        % Two boards set to same board number
        ERR_BOARDCLOSED   = int32(-10);       % Board is not open
        ERR_CREATEMUTEX   = int32(-11);       % Can't create mutex
        ERR_MEMORYMAP     = int32(-12);     
        
        
        
        % Can't map board to memory address
        ERR_MALLOC        = int32(-13);       % Can't allocate memory
        ERR_FIFOOVERFLOW  = int32(-15);       % Counter's snapshot fifo overflowed
        ERR_LOCALBUS      = int32(-16);       % Can't read local bus (register contains illegal value)
        ERR_OSSPECIFIC    = int32(-100);      % Port-specific error (base error number)
       
        % Analog input range codes
        ADC_GAIN_1        = 0;           % -10V to +10V
        ADC_GAIN_2        = 1;           % -5V to +5V
        ADC_GAIN_5        = 2;           % -2V to +2V
        ADC_GAIN_10       = 3;           % -1V to +1V
        
        % ADC hardware trigger
        ADC_TRIGENABLE    = bitshift(uint32(1), 7);     % Enable hardware triggering
        ADC_TRIGRISING    = bitshift(uint32(1), 6);     % Start burst on trigger rising edge
        ADC_TRIGFALLING   = uint32(0);                  % Start burst on trigger falling edge

        % Analog output range codes
        DAC_SPAN_0_5      = 0;           % 0 to +5V
        DAC_SPAN_0_10     = 1;           % 0 to +10V
        DAC_SPAN_5_5      = 2;           % -5V to +5V
        DAC_SPAN_10_10    = 3;           % -10V to +10V
        
        % Bank selector codes
        BANKSEL_RUNMODE   = 0;           % Normal operation
        BANKSEL_SAFEMODE  = 1;           % Safemode operation

        % Counter snapshot reason bit masks
        SSRMASK_QUADERR   = bitshift(uint32(1), 8);    % Quadrature error
        SSRMASK_SOFT      = bitshift(uint32(1), 7);    % Soft snapshot
        SSRMASK_EXTRISE   = bitshift(uint32(1), 6);    % ExtIn rising edge
        SSRMASK_EXTFALL   = bitshift(uint32(1), 5);    % ExtIn falling edge
        SSRMASK_IXRISE    = bitshift(uint32(1), 4);    % Index rising edge
        SSRMASK_IXFALL    = bitshift(uint32(1), 3);    % Index falling edge
        SSRMASK_ZERO      = bitshift(uint32(1), 2);    % Zero counts reached
        SSRMASK_MATCH1    = bitshift(uint32(1), 1);    % Compare1 register match
        SSRMASK_MATCH0    = bitshift(uint32(1), 0);    % Compare0 register match

        % Snapshot enable bit masks
        % Capture all snapshots (don't disable after first snapshot)
        SS_ALL_EXTRISE    = bitshift(uint32(1), 6);    % ExtIn rising edge
        SS_ALL_EXTFALL    = bitshift(uint32(1), 5);    % ExtIn falling edge
        SS_ALL_IXRISE     = bitshift(uint32(1), 4);    % Index rising edge
        SS_ALL_IXFALL     = bitshift(uint32(1), 3);    % Index falling edge
        SS_ALL_ZERO       = bitshift(uint32(1), 2);    % Zero counts reached
        SS_ALL_MATCH1     = bitshift(uint32(1), 1);    % Compare1 register match
        SS_ALL_MATCH0     = bitshift(uint32(1), 0);    % Compare0 register match
        % Capture one snapshot (disable upon first snapshot)
        SS_FIRST_EXTRISE  = bitshift(uint32(65537), 6);    % ExtIn rising edge
        SS_FIRST_EXTFALL  = bitshift(uint32(65537), 5);    % ExtIn falling edge
        SS_FIRST_IXRISE   = bitshift(uint32(65537), 4);    % Index rising edge
        SS_FIRST_IXFALL   = bitshift(uint32(65537), 3);    % Index falling edge
        SS_FIRST_ZERO     = bitshift(uint32(65537), 2);    % Zero counts reached
        SS_FIRST_MATCH1   = bitshift(uint32(65537), 1);    % Compare1 register match
        SS_FIRST_MATCH0   = bitshift(uint32(65537), 0);    % Compare0 register match

        % ControlWrite/ControlRead bit masks
        CONFIG_XSF        = bitshift(uint32(1), 3);    % Enable DIO47 to set SAF
        CONFIG_SAF        = bitshift(uint32(1), 1);    % SafeMode active

        % Watchdog configuration bit masks
        WD_GSN            = bitshift(uint32(1), 6);    % Assert NMI upon timer1 timeout
        WD_SEN            = bitshift(uint32(1), 4);    % Activate safemode upon timer0 timeout
        WD_NIE            = bitshift(uint32(1), 3);    % Connect timer1 output to dio routing matrix NMI net
        WD_PEN            = bitshift(uint32(1), 2);    % Enable RST output to pulse
        WD_OEN            = bitshift(uint32(1), 0);    % Connect RST generator to dio routing matrix RST net

        % Array indices for watchdog timing parameters
        WD_DELAY0         = 0;           % Timer0 interval (20 ns resolution)
        WD_DELAY1         = 1;           % Timer1 interval (20 ns resolution)
        WD_DELAY2         = 2;           % Timer2 interval (20 ns resolution)
        WD_PWIDTH         = 3;           % RST pulse width (ignored if PEN=0)
        WD_PGAP           = 4;           % Time gap between RST pulses (ignored if PEN=0)

        % SAFEN bit masks
        SAFEN_SWE         = bitshift(uint32(1), 1);    % Set write enable for safemode registers
        SAFEN_SWD         = bitshift(uint32(1), 0);    % Clear write enable for safemode registers

        % Register Write/Bitset/Bitclear modes
        BITWRITE          = 0;           % Write all bits unconditionally
        BITCLR            = 1;           % Clear designated bits; leave others unchanged
        BITSET            = 2;           % Set designated bits; leave others unchanged

        % Wait types
        WAIT_ALL          = 0;           % Wait for all listed events
        WAIT_ANY          = 1;           % Wait for any listed event

        % Wait durations
        WAIT_INFINITE     = intmax('uint32');  % 0xFFFFFFFF - tmax value to use on any blocking function that needs infinite wait time

        % Counter mode register bit masks ------------------------------

                                            % ExtIn polarity
        CM_IP_NORMAL      = bitshift(uint32(0), 30);   %   pass-thru
        CM_IP_INVERT      = bitshift(uint32(1), 30);   %   invert
                                            % ExtIn function
        CM_IM_OFF         = bitshift(uint32(0), 28);   %   not used
        CM_IM_COUNTEN     = bitshift(uint32(1), 28);   %   count permissive
        CM_IM_PRELOADEN   = bitshift(uint32(2), 28);   %   preload permissive
                                            % Retriggerability
        CM_NR_RETRIG      = bitshift(uint32(0), 23);   %   enable preloading when counts not zero
        CM_NR_NORETRIG    = bitshift(uint32(1), 23);   %   disable preloading when counts not zero
                                            % Count direction
        CM_UD_NORMAL      = bitshift(uint32(0), 22);   %   count up
        CM_UD_REVERSE     = bitshift(uint32(1), 22);   %   count down
                                            % Preload usage
        CM_BP_SINGLE      = bitshift(uint32(0), 21);   %   use only Preload0
        CM_BP_BOTH        = bitshift(uint32(1), 21);   %   toggle between Preload0 and Preload1
                                            % ExtOut function
        CM_OM_OFF         = bitshift(uint32(0), 18);   %   always '0'
        CM_OM_MATCH       = bitshift(uint32(1), 18);   %   pulse upon compare0 or Compare1 match snapshot
        CM_OM_PRELOAD     = bitshift(uint32(2), 18);   %   active when Preload1 is selected
        CM_OM_NOTZERO     = bitshift(uint32(3), 18);   %   active when counts != zero
        CM_OM_ZERO        = bitshift(uint32(4), 18);   %   active when counts == zero
                                            % ExtOut polarity
        CM_OP_NORMAL      = bitshift(uint32(0), 17);   %   active high
        CM_OP_INVERT      = bitshift(uint32(1), 17);   %   active low
                                            % Preload triggers
        CM_PX_START       = bitshift(uint32(1), 24);   %   upon counter enabled
        CM_PX_IXHIGH      = bitshift(uint32(1), 16);   %   while Index active (holds counts at preload value)
        CM_PX_IXRISE      = bitshift(uint32(1), 15);   %   upon Index rising edge
        CM_PX_IXFALL      = bitshift(uint32(1), 14);   %   upon Index falling edge
        CM_PX_ZERO        = bitshift(uint32(1), 13);   %   upon zero counts reached
        CM_PX_MATCH1      = bitshift(uint32(1), 12);   %   upon Compare1 counts reached
        CM_PX_MATCH0      = bitshift(uint32(1), 11);   %   upon Compare0 counts reached
                                            % Count enable trigger
        CM_TE_STARTUP     = bitshift(uint32(0), 9);    %   upon counter enabled
        CM_TE_IXRISE      = bitshift(uint32(1), 9);    %   upon Index rising edge
        CM_TE_PRELOAD     = bitshift(uint32(2), 9);    %   upon preloading
                                            % Count disable trigger
        CM_TD_NEVER       = bitshift(uint32(0), 7);    %   upon counter disabled
        CM_TD_IXFALL      = bitshift(uint32(1), 7);    %   upon Index falling edge
        CM_TD_ZERO        = bitshift(uint32(2), 7);    %   upon zero counts reached
                                            % Clock mode
        CM_K_ARISE        = bitshift(uint32(0), 4);    %   single-phase, ClkA rising edge
        CM_K_AFALL        = bitshift(uint32(1), 4);    %   single-phase, ClkA falling edge
        CM_K_1MHZ         = bitshift(uint32(2), 4);    %   single-phase, 1 MHz internal clock
        CM_K_50MHZ        = bitshift(uint32(3), 4);    %   single-phase, 50 MHz internal clock
        CM_K_CASCADE      = bitshift(uint32(4), 4);    %   single-phase, cascade-out of adjacent channel
        CM_K_QUADX1       = bitshift(uint32(5), 4);    %   quadrature x1, ClkA and ClkB
        CM_K_QUADX2       = bitshift(uint32(6), 4);    %   quadrature x2, ClkA and ClkB
        CM_K_QUADX4       = bitshift(uint32(7), 4);    %   quadrature x4, ClkA and ClkB
                                            % Index input source
        CM_XS_EXTNORMAL   = 0;           %   IX input, pass-thru
        CM_XS_EXTINVERT   = 1;           %   IX input, inverted
        CM_XS_EXTOUT0     = 2;           %   ExtOut of any counter (CTR in range 0..5)
        CM_XS_EXTOUT1     = 3;
        CM_XS_EXTOUT2     = 4;
        CM_XS_EXTOUT3     = 5;
        CM_XS_EXTOUT4     = 6;
        CM_XS_EXTOUT5     = 7;
        CM_XS_R1HZ        = 8;           %   0.1 Hz internal tick generator
        CM_XS_1HZ         = 9;           %   1 Hz internal tick generator
        CM_XS_10HZ        = 10;          %   10 Hz internal tick generator
        CM_XS_100HZ       = 11;          %   100 Hz internal tick generator
        CM_XS_1KHZ        = 12;          %   1 kHz internal tick generator
        CM_XS_10KHZ       = 13;          %   10 kHz internal tick generator
        CM_XS_100KHZ      = 14;          %   100 kHz internal tick generator
        CM_XS_1MHZ        = 15;          %   1 MHz internal tick generator

    end % constants
    
    methods
       
        function obj = s826()
            
        end
    end
    
    
    
    methods (Static)
        
        % Computed constants ================================================================================
        
        % Router selector codes for ExtIn signal source
        function [val] = RouterCode(N, min, max, offset)    % helper
            if ((N < min) || (N > max))
                error("Illegal signal source specified for ExtIn");
            else
                val = N + offset;                
            end
        end
        function [routeid] = INSRC_DIO(N)               % DIO channel N (0:47)
            routeid = s826.RouterCode(N, 0, 47, 0);
        end
        function [routeid] = INSRC_EXTOUT(N)            % Counter channel N (0:5) ExtOut
            routeid = s826.RouterCode(N, 0, 5, 48);
        end
        function [routeid] = INSRC_VDIO(N)              % Virtual DIO channel N (0:5)
            routeid = s826.RouterCode(N, 0, 5, 54);
        end
        
        % Sub-wrapper for simple API functions with pointer arg ===============================================
                
        function [errcode, data] = ApiFuncReadUint(funcname, board)
            pdata  = libpointer('uint32Ptr', 0);
            errcode = calllib('s826', funcname, board, pdata);
            data = pdata.value;
            clear pdata;
        end
        
        % API function wrappers =============================================================================
        
        % Wrapper functions have similar names to their underlying API functions.
        % For example, S826_SystemOpen() is invoked by calling s826.SystemOpen().
        % Refer to Sensoray's Model 826 Instruction Manual for API information.
        
        % SYSTEM ------------------------------------------------
        
        % Get version info.
        function [errcode, api, driver, bdrev, fpgarev] = VersionRead(board)
            papi     = libpointer('uint32Ptr', 0);
            pdriver  = libpointer('uint32Ptr', 0);
            pbdrev   = libpointer('uint32Ptr', 0);
            pfpgarev = libpointer('uint32Ptr', 0);
            errcode  = calllib('s826', 'S826_VersionRead', board, papi, pdriver, pbdrev, pfpgarev);
            api      = papi.value;
            driver   = pdriver.value;
            bdrev    = pbdrev.value;
            fpgarev  = pfpgarev.value;
            clear papi pdriver pbdrev pfpgarev;
        end
        
        % Load the API, open it and detect all 826 boards
        function [errcode, boardflags] = SystemOpen(dllPath, hdrPath)
            if (~libisloaded('s826'))
                loadlibrary(dllPath, hdrPath, 'alias', 's826');
                if (~libisloaded('s826'))
                    error ("loadlibrary() failed: Can't load s826.dll");
                end
            end
            boardflags = calllib('s826', 'S826_SystemOpen'); % open API and detect all boards
            if (boardflags >= 0)
                errcode = s826.ERR_OK;
            else
                boardflags = 0;
                unloadlibrary s826;
            end
        end
        
        % Close the API and unload it.
        function errcode = SystemClose()
            if (libisloaded('s826'))
                errcode = calllib('s826', 'S826_SystemClose');  % close API
                unloadlibrary s826;                             % unload API
            else
                errcode = s826.ERR_OK;
            end            
        end
        
        function [errcode, timestamp] = TimestampRead(board)
            [errcode, timestamp] = s826.ApiFuncReadUint('S826_TimestampRead', board);
        end
        
        % SAFEMODE ----------------------------------------------------
        
        function errcode = SafeControlWrite(board, settings, mode)
            errcode = calllib('s826', 'S826_SafeControlWrite', board, settings, mode);
        end
        
        function errcode = SafeWrenWrite(board, enable)
            errcode = calllib('s826', 'S826_SafeWrenWrite', board, enable);
        end
        
        function [errcode, settings] = SafeControlRead(board)
            [errcode, settings] = s826.ApiFuncReadUint('S826_SafeControlRead', board);
        end
        
        function [errcode, enable] = SafeWrenRead(board)
            [errcode, enable] = s826.ApiFuncReadUint('S826_SafeWrenRead', board);
        end
        
        % ADC ----------------------------------------------------
        
        function errcode = AdcEnableWrite(board, enable)
            errcode = calllib('s826', 'S826_AdcEnableWrite', board, enable);
        end

        function errcode = AdcSlotConfigWrite(board, slot, chan, tsettle, range)
            errcode = calllib('s826', 'S826_AdcSlotConfigWrite', board, slot, chan, tsettle, range);
        end

        function errcode = AdcSlotlistWrite(board, slotlist, mode)
            errcode = calllib('s826', 'S826_AdcSlotlistWrite', board, slotlist, mode);
        end

        function errcode = AdcTrigModeWrite(board, trigmode)
            errcode = calllib('s826', 'S826_AdcTrigModeWrite', board, trigmode);
        end

        function errcode = AdcWaitCancel(board, slotlist)
            errcode = calllib('s826', 'S826_AdcWaitCancel', board, slotlist);
        end
        
        function [errcode, data] = AdcEnableRead(board)
            [errcode, data] = s826.ApiFuncReadUint('S826_AdcEnableRead', board);
        end
        
        function [errcode, slotlist] = AdcSlotlistRead(board)
            [errcode, slotlist] = s826.ApiFuncReadUint('S826_AdcSlotlistRead', board);
        end
        
        function [errcode, slotlist] = AdcStatusRead(board)
            [errcode, slotlist] = s826.ApiFuncReadUint('S826_AdcStatusRead', board);
        end
        
        function [errcode, trigmode] = AdcTrigModeRead(board)
            [errcode, trigmode] = s826.ApiFuncReadUint('S826_AdcTrigModeRead', board);
        end
        
        function [errcode, adcdata, timestamps, slotlist_out] = AdcRead(board, slotlist_in, tmax)
            pdata        = libpointer('int32Ptr', zeros(16, 1));
            ptstamps     = libpointer('uint32Ptr', zeros(16, 1));
            pslotlist    = libpointer('uint32Ptr', slotlist_in); % flags indicating slots of interest
            errcode      = calllib('s826', 'S826_AdcRead', board, pdata, ptstamps, pslotlist, tmax);
            adcdata      = pdata.value;
            timestamps   = ptstamps.value;
            slotlist_out = pslotlist.value; % flags indicating slots that have fresh data
            clear pdata ptstamps pslotlist;
        end
        
        function [errcode, chan, tsettle, range] = AdcSlotConfigRead(board)
            pchan    = libpointer('uint32Ptr', 0);
            ptsettle = libpointer('uint32Ptr', 0);
            prange   = libpointer('uint32Ptr', 0);
            errcode  = calllib('s826', 'S826_AdcSlotConfigRead', board, pchan, ptsettle, prange);
            chan     = pchan.value;
            tsettle  = psettle.value;
            range    = prange.value;
            clear pchan ptsettle prange;
        end
        
        % DAC ----------------------------------------------------
        
        function errcode = DacDataWrite(board, chan, setpoint, safemode)
            errcode = calllib('s826', 'S826_DacDataWrite', board, chan, setpoint, safemode);
        end
        
        function errcode = DacRangeWrite(board, chan, range, safemode)
            errcode = calllib('s826', 'S826_DacRangeWrite', board, chan, range, safemode);
        end
        
        function [errcode, range, setpoint] = DacRead(board, chan, safemode)
            prange    = libpointer('uint32Ptr', 0);
            psetpoint = libpointer('uint32Ptr', 0);
            errcode   = calllib('s826', 'S826_DacRead', board, chan, prange, psetpoint, safemode);
            range     = prange.value;
            setpoint  = psetpoint.value;
            clear prange psetpoint;
        end
        
        % COUNTERS ----------------------------------------------------
        
        function errcode = CounterCompareWrite(board, chan, regid, counts)
            errcode = calllib('s826', 'S826_CounterCompareWrite', board, chan, regid, counts);
        end
        
        function errcode = CounterExtInRoutingWrite(board, chan, route)
            errcode = calllib('s826', 'S826_CounterExtInRoutingWrite', board, chan, route);
        end
        
        function errcode = CounterFilterWrite(board, chan, cfg)
            errcode = calllib('s826', 'S826_CounterFilterWrite', board, chan, cfg);
        end
        
        function errcode = CounterModeWrite(board, chan, mode)
            errcode = calllib('s826', 'S826_CounterModeWrite', board, chan, mode);
        end
        
        function errcode = CounterPreload(board, chan, level, sticky)
            errcode = calllib('s826', 'S826_CounterPreload', board, chan, level, sticky);
        end
        
        function errcode = CounterPreloadWrite(board, chan, reg, counts)
            errcode = calllib('s826', 'S826_CounterPreloadWrite', board, chan, reg, counts);
        end
        
        function errcode = CounterSnapshot(board, chan)
            errcode = calllib('s826', 'S826_CounterSnapshot', board, chan);
        end
        
        function errcode = CounterSnapshotConfigWrite(board, chan, ctrl, mode)
            errcode = calllib('s826', 'S826_CounterSnapshotConfigWrite', board, chan, ctrl, mode);
        end
        
        function errcode = CounterStateWrite(board, chan, run)
            errcode = calllib('s826', 'S826_CounterStateWrite', board, chan, run);
        end
        
        function errcode = CounterWaitCancel(board, chan)
            errcode = calllib('s826', 'S826_CounterWaitCancel', board, chan);
        end
        
        function [errcode, counts] = CounterCompareRead(board, chan, regid)
            pcounts = libpointer('uint32Ptr', 0);
            errcode = calllib('s826', 'S826_CounterCompareRead', board, chan, regid, pcounts);
            counts  = pcounts.value;
            clear pcounts;
        end
        
        function [errcode, route] = CounterExtInRoutingRead(board, chan)
            proute  = libpointer('uint32Ptr', 0);
            errcode = calllib('s826', 'S826_CounterExtInRoutingRead', board, chan, proute);
            route   = proute.value;
            clear proute;
        end
        
        function [errcode, cfg] = CounterFilterRead(board, chan)
            pcfg    = libpointer('uint32Ptr', 0);
            errcode = calllib('s826', 'S826_CounterFilterRead', board, chan, pcfg);
            cfg     = pcfg.value;
            clear pcfg;
        end
        
        function [errcode, mode] = CounterModeRead(board, chan)
            pmode   = libpointer('uint32Ptr', 0);
            errcode = calllib('s826', 'S826_CounterModeRead', board, chan, pmode);
            mode    = pmode.value;
            clear pmodeinfo;
        end
        
        function [errcode, counts] = CounterPreloadRead(board, chan, reg)
            pcounts  = libpointer('uint32Ptr', 0);
            errcode  = calllib('s826', 'S826_CounterPreloadRead', board, chan, reg, pcounts);
            counts   = pcounts.value;
            clear pcounts;
        end
        
        function [errcode, counts] = CounterRead(board, chan)
            pcounts = libpointer('uint32Ptr', 0);
            errcode = calllib('s826', 'S826_CounterRead', board, chan, pcounts);
            counts  = pcounts.value;
            clear pcounts;
        end
        
        function [errcode, ctrl] = CounterSnapshotConfigRead(board, chan)
            pctrl   = libpointer('uint32Ptr', 0);
            errcode = calllib('s826', 'S826_CounterSnapshotConfigRead', board, chan, pctrl);
            ctrl    = pctrl.value;
            clear pctrl;
        end
        
        function [errcode, counts, tstamp, reason] = CounterSnapshotRead(board, chan, tmax)
             pcounts  = libpointer('uint32Ptr', 0);
             ptstamp  = libpointer('uint32Ptr', 0);
             preason  = libpointer('uint32Ptr', 0);
             errcode  = calllib('s826', 'S826_CounterSnapshotRead', board, chan, pcounts, ptstamp, preason, tmax);
             counts   = pcounts.value;
             tstamp   = ptstamp.value;
             reason   = preason.value;
             clear pcounts ptstamp preason;
        end
        
        function [errcode, status] = CounterStatusRead(board, chan)
             pstatus = libpointer('uint32Ptr', 0);
             errcode = calllib('s826', 'S826_CounterStatusRead', board, chan, pstatus);
             status  = pstatus.value;
             clear pstatus;
        end
        
        % DIO ----------------------------------------------------
        
        function errcode = DioOutputWrite(board, data, mode)
            errcode = calllib('s826', 'S826_DioOutputWrite', board, data, mode);
        end
        
        function errcode = DioSafeWrite(board, data, mode)
            errcode = calllib('s826', 'S826_DioSafeWrite', board, data, mode);
        end
        
        function errcode = DioCapEnablesWrite(board, rising, falling, mode)
            errcode = calllib('s826', 'S826_DioCapEnablesWrite', board, rising, falling, mode);
        end
        
        function errcode = DioFilterWrite(board, interval, enables)
            errcode = calllib('s826', 'S826_DioFilterWrite', board, interval, enables);
        end
        
        function errcode = DioOutputSourceWrite(board, data)
            errcode = calllib('s826', 'S826_DioOutputSourceWrite', board, data);
        end
        
        function errcode = DioSafeEnablesWrite(board, enables)
            errcode = calllib('s826', 'S826_DioSafeEnablesWrite', board, enables);
        end
        
        function errcode = DioWaitCancel(board, data)
            errcode = calllib('s826', 'S826_DioWaitCancel', board, data);
        end
        
        function [errcode, data] = S826_DioOutputRead(board)
            pdata   = libpointer('uint32Ptr', [0 0]);
            errcode = calllib('s826', 'S826_DioOutputRead', board, pdata);
            data    = pdata.value;
            clear pdata;
        end
        
        function [errcode, data] = DioInputRead(board)
             pdata   = libpointer('uint32Ptr', [0 0]);
             errcode = calllib('s826', 'S826_DioInputRead', board, pdata);
             data    = pdata.value;
             clear pdata;
        end
        
        function [errcode, rising, falling] = DioCapEnablesRead(board)
            prising  = libpointer('uint32Ptr', [0 0]);
            pfalling = libpointer('uint32Ptr', [0 0]);
            errcode  = calllib('s826', 'S826_DioCapEnablesRead', board, prising, pfalling);
            rising   = prising.value;
            falling  = pfalling.value;
            clear prising pfalling;
        end
        
        function [errcode, chanlist_out] = DioCapRead(board, chanlist_in, waitall, tmax)
            pchanlist = libpointer('uint32Ptr', chanlist_in); % flags indicating DIOs of interest
            errcode  = calllib('s826', 'S826_DioCapRead', board, pchanlist, waitall, tmax);
            chanlist_out = pchanlist.value;  % flags indicating DIOs that had captured events
            clear pchanlist;
        end
        
        function [errcode, interval, enables] = DioFilterRead(board)
            pinterval = libpointer('uint32Ptr', 0);
            penables  = libpointer('uint32Ptr', [0 0]);
            errcode   = calllib('s826', 'S826_DioFilterRead', board, pinterval, penables);
            interval  = pinterval.value;
            enables   = penables.value;
            clear pinterval;
        end
        
        function [errcode, data] = DioOutputSourceRead(board)
            pdata   = libpointer('uint32Ptr', [0 0]);
            errcode = calllib('s826', 'S826_DioOutputSourceRead', board, pdata);
            data = pdata.value;
            clear pdata;
        end
        
        function [errcode, enables] = DioSafeEnablesRead(board)
            penables = libpointer('uint32Ptr', [0 0]);
            errcode  = calllib('s826', 'S826_DioSafeEnablesRead', board, penables);
            enables  = penables.value;
            clear penables;
        end
        
        function [errcode, data] = DioSafeRead(board)
            pdata   = libpointer('uint32Ptr', [0 0]);
            errcode = calllib('s826', 'S826_DioSafeRead', board, pdata);
            data    = pdata.value;
            clear pdata;
        end
        
        % BURIED DIO ----------------------------------------------------
        
        function errcode = VirtualWrite(board, data, mode)
            errcode = calllib('s826', 'S826_VirtualWrite', board, data, mode);
        end
        
        function errcode = VirtualSafeWrite(board, data, mode)
            errcode = calllib('s826', 'S826_VirtualSafeWrite', board, data, mode);
        end
        
        function errcode = VirtualSafeEnablesWrite(board, enables)
            errcode = calllib('s826', 'S826_VirtualSafeEnablesWrite', board, enables);
        end
        
        function [errcode, data] = VirtualRead(board)
            [errcode, data] = s826.ApiFuncReadUint('S826_VirtualRead', board);
        end
        
        function [errcode, data] = VirtualSafeRead(board)
            [errcode, data] = s826.ApiFuncReadUint('S826_VirtualSafeRead', board);
        end
        
        function [errcode, enables] = VirtualSafeEnablesRead(board)
            [errcode, enables] = s826.ApiFuncReadUint('S826_VirtualSafeEnablesRead', board);
        end
        
        % WATCHDOG ----------------------------------------------------
        
        function errcode = WatchdogEnableWrite(board, enable)
            errcode = calllib('s826', 'S826_WatchdogEnableWrite', board, enable);
        end
        
        function errcode = WatchdogConfigWrite(board, config, timers)
            errcode = calllib('s826', 'S826_WatchdogConfigWrite', board, config, timers);
        end
        
        function errcode = WatchdogKick(board, data)
            errcode = calllib('s826', 'S826_WatchdogKick', board, data);
        end
        
        function errcode = WatchdogEventWait(board, tmax)
            errcode = calllib('s826', 'S826_WatchdogEventWait', board, tmax);
        end
        
        function errcode = WatchdogWaitCancel(board)
            errcode = calllib('s826', 'S826_WatchdogWaitCancel', board);
        end
        
        function [errcode, enable] = WatchdogEnableRead(board)
            [errcode, enable] = s826.ApiFuncReadUint('S826_WatchdogEnableRead', board);
        end
        
        function [errcode, status] = WatchdogStatusRead(board)
            [errcode, status] = s826.ApiFuncReadUint('S826_WatchdogStatusRead', board);
        end        
        
        function [errcode, timers] = WatchdogConfigRead(board)
            ptimers = libpointer('uint32Ptr', zeros(5, 1));
            errcode = calllib('s826', 'S826_WatchdogConfigRead', board, ptimers);
            timers  = ptimers.value;
            clear ptimers;
        end
    end
end

