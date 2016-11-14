function process_packet(obj, command, response)        
% Processes mount response based on the the type of command sent. If no
% appropriate response method exists, then does nothing.

%     disp([command ', ' response]);

    % Number of bits in response (used for timestamp)
    response_size = numel(response) * 8;                    % 8 bits/char
    transfer_time = seconds(response_size/obj.baud_rate);   % in s
    ts = now - transfer_time;
    
    if strcmp(command, ':GAS')
        % GPS
        obj.status_back.gps = str2double(response(1));
        switch obj.status_back.gps
            case 0
                obj.status.gps = 'off';
            case 1
                obj.status.gps = 'on';
            otherwise
                obj.status.gps = 'extracted';
        end
        
        % System
        obj.status_back.system = str2double(response(2));
        switch obj.status_back.system
            case 0
                obj.status.system = 'stopped (not at zero position)';
            case 1
                obj.status.system = 'tracking (PEC disabled)';
            case 2
                obj.status.system = 'slewing';
            case 3
                obj.status.system = 'guiding';
            case 4
                obj.status.system = 'meridian flipping';
            case 5
                obj.status.system = 'tracking (PEC enabled)';
            case 6
                obj.status.system = 'parked';
            otherwise
                obj.status.system = 'stopped (at zero position)';
        end
        
        % Track rate
        obj.status_back.track_rate = str2double(response(3));
        switch obj.status_back.track_rate
            case 0
                obj.status.track_rate = 'sidereal'; 
            case 1
                obj.status.track_rate = 'lunar';
            case 2
                obj.status.track_rate = 'solar';
            case 3
                obj.status.track_rate = 'King';
            otherwise
                obj.status.track_rate = 'custom';
        end
        
        % Slew rate
        obj.status_back.slew_rate = str2double(response(4));
        switch obj.status_back.slew_rate
            case 1
                obj.status.slew_rate = '1x sidereal';
            case 2
                obj.status.slew_rate = '2x sidereal';
            case 3
                obj.status.slew_rate = '8x sidereal';
            case 4
                obj.status.slew_rate = '16x sidereal';
            case 5
                obj.status.slew_rate = '64x sidereal';
            case 6
                obj.status.slew_rate = '128x sidereal';
            case 7
                obj.status.slew_rate = '256x sidereal';
            case 8
                obj.status.slew_rate = '512x sidereal';
            otherwise
                obj.status.slew_rate = '1400x sidereal (max)';
        end
        
        % Time source
        obj.status_back.time_source = str2double(response(5));
        switch obj.status_back.time_source
            case 1
                obj.status.time_source = 'RS-232 port';
            case 2
                obj.status.time_source = 'hand controller';
            otherwise
                obj.status.time_source = 'gps';
        end
        
        % Hemisphere
        obj.status_back.hemisphere = str2double(response(6));
        switch obj.status_back.hemisphere
            case 0
                obj.status.hemisphere = 'south';
            otherwise
                obj.status.hemisphere = 'north';
        end
    end
        
    % Angles
    if strcmp(command, ':GEC')
        obj.pos(1) = str2double(response(10:17));           % RA
        obj.pos(2) = str2double(response(1:9));             % DEC
        obj.timestamps.angles = datenum(ts);
        
    % Time
    elseif strcmp(command, ':GLT')
        obj.date = response(6:11);
        obj.time = response(12:17);
        obj.utc_offset = response(1:4);
        obj.timestamps.gps_time = datenum(ts);
        
    % Latitude
    elseif strcmp(command, ':Gt')
        obj.gps(1) = str2double(response(1:7));
        obj.timestamps.latitude = datenum(ts);
        
    % Longitude
    elseif strcmp(command, ':Gg')
        obj.gps(2) = str2double(response(1:7));
        obj.timestamps.longitude = datenum(ts);
        
        % Add readings and increment index (we do this here because
        % get-longitude is the last command we send when we're getting a
        % reading)
        obj.readings(obj.readings_idx).position = obj.pos;
        obj.readings(obj.readings_idx).date = obj.date;
        obj.readings(obj.readings_idx).time = obj.time;
        obj.readings(obj.readings_idx).utc_offset = obj.utc_offset;
        obj.readings(obj.readings_idx).gps = obj.gps;
        obj.readings(obj.readings_idx).timestamps = obj.timestamps;
        obj.readings_idx = obj.readings_idx + 1;
        
    % Slew
    elseif strcmp(command, ':MS')
        if strcmp(response, '1')
            % Do nothing
        else
            obj.dmsg('Can''t slew there (coordinates below horizon). \n');
        end
    end
    
end