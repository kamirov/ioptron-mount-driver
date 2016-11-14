classdef iopt_mount < handle
% Driver for the iOptron iEQ30-Pro telescope mount
% 
% Usage:
%     - Use start_readings() and stop_readings() to start/stop
%       asynchronously reading position, GPS, and datetime data
%     - Use save_readings() and clear_readings() to do just that
%     - Use move() to go to a given RA and DEC. 
%     - Use stop() to stop moving (also stops readings).
%     - Use make_survey(), remake_survey(), and start_survey() to perform sky surveys
%     
% Known glitches:
%     - Can't send any synchronous commands while there are still
%       asynchronous commands in the command queue. Bad juju if you do.
    
    properties
        pos = [NaN NaN]                 % [RA (ms), DEC (0.01asec)]                         
        gps = [NaN NaN]                 % [lat (asec), lon (asec)]
        date = NaN;                     % YY:MM:DD
        time = NaN;                     % HH:MM:SS
        utc_offset = NaN;               % [min]
        timestamps = struct();          % When readings came in
        readings = struct();            % Struct containing all readings and their timestamps
        status = struct();              % Current mount states
        survey = struct();              % Sky survey data
    end
    
    
    properties(Access = private)
        readings_idx = 1;               % Current reading index
        async_processing = 0;           % Flag meaning we're currently in the async processing calback
        command_queue = {};             % Commands sent to the mount
        command_timeout = 1;            % Max time (s) we wait for commands to process on the mount
        debug_mode = true;              % Enables debug messages
        process_timer;                  % Timer to continuously take readings
        dir;                            % Class directory
        ser;                            % Serial object
        port;                           % Serial object port
        baud_rate = 9600;               % [bits/s]
        start_times = [];               % Timestamps of when each queued command was sent
        timeout_timer;                  % Timer to trigger timeout checks and synchronous command responses
        date_fmt = 'yyyymmddTHHMMSS';   % Date format used with files
        status_back;                    % Numeric representation of the system status
%         slew_tic;
%         tocs;
    end
    
   
    methods
        function obj = iopt_mount(com_port)
        % Constructor
        
            obj.dir = mfilename('fullpath');
            obj.dir = obj.dir(1:end-23);    % Get the folder of the class. Not pretty, fix this.
            
            obj.confirm_dependencies();
            obj.init_comm(com_port);
            obj.init_timers();
            obj.init_firmware();
            obj.init_state();
            
            obj.dmsg('Platform Ready\n');
        end
    end     
end