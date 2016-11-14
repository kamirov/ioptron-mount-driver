function run_survey(obj)
% Runs survey currently on the object

    if isempty(fieldnames(obj.survey))
        error('No survey stored. Call make_survey()');
    end
    
    if nargin < 3
        control = [];
    end
    
    obj.survey_log('Started survey.');
    
    % Get current trajectory point
    num_traj = size(obj.survey.trajectory, 1);
    for traj_idx = 1:num_traj
        if obj.survey.trajectory(traj_idx, 1) > now
            if traj_idx ~= 1
                traj_idx = traj_idx - 1;
            end
            break;
        end
    end
        
    % Run survey
    num_images = 0;
    reset();
    move();
    while traj_idx ~= num_traj
        if traj_idx == num_traj
            t_next = obj.survey.trajectory(end, 1);
        else
            t_next = obj.survey.trajectory(traj_idx+1, 1);
        end
        
        if now > t_next
            if num_images > 0
                obj.survey_save_readings(traj_idx);
            end
                
            traj_idx = traj_idx + 1;

            reset();
            move();
        end
        read();
    end
    
    obj.survey_save_readings(traj_idx);
    obj.survey_log('Finished survey.');
    
    function reset()
    % Resets reading related values
        num_images = 0;
        obj.survey.readings = struct('raw', [], ...
                                     'processed', []);
        obj.clear_readings();
    end
    
    function move()
    % Sends move command to the mount, updates survey log
        ra = obj.survey.trajectory(traj_idx, 2);
        dec = obj.survey.trajectory(traj_idx, 3);
        obj.move([ra, dec], 0, 1, 1);
        
        msg_ra = [num2str(ra), '°'];
        msg_dec = [num2str(dec), '°'];
        cur_idx = num2str(traj_idx);
        last_idx = num2str(num_traj);
        
        msg = ['Slewing to ' msg_ra ', ' msg_dec ' [ra, dec] ' ...
               ' (' cur_idx ' of ' last_idx ').'];
        obj.dmsg([msg, '\n']);
        obj.survey_log(msg)

        obj.wait_for_slew();          % Hold until motion finishes
        msg = 'Finished slewing.';     
        
        % Output next point's timestamp (this helps ascertain if a survey
        % was cancelled or if the computer crashed)
        if traj_idx ~= num_traj
            msg = [msg ' Next point at ' datestr(obj.survey.trajectory(traj_idx+1, 1), 'HH:MM:SS') '.'];
        end
        obj.dmsg([msg, '\n']);
        obj.survey_log(msg)
        
        obj.send_sync(':ST0#');      % Disable tracking (making this async leads to timeouts on the status update)
        obj.update_status();         % Doesn't have to be synchronous
        obj.survey_log('Disabled tracking.');
        
    end

    function read()
        % Takes an image. Stores raw timestamps and mount readings.
        % Also stores some processed values
        
        % Mount readings
        timestamps.t_pre_gps_request = now;
        obj.send(':GLT#');   % Request GPS time
        timestamps.t_post_gps_request = now;
        
        % Take images
        % Insert any image taking code here

        % More mount readings 
        obj.send(':GEC#:Gt#:Gg#');   % Request ra/dec, lat, lon
        
        % Processed value - timestamp
        dt_gps = timestamps.t_post_gps_request - timestamps.t_pre_gps_request;
        mount_time = datenum([obj.date ' ' obj.time], 'yymmdd HHMMSS');
        proc_timestamp = datenum(local_time_to_utc(mount_time + dt_gps));

        % Processed value - ra/dec
        dt_image = timestamps.t_post_image_exposure - timestamps.t_post_gps_request;
        rot_earth = 360 / (24 * 3600);
        ra = (obj.pos(1)*15)/(3600*1000);     % [ms -> deg]
        dec = obj.pos(2) / (3600*100);        % [0.01 asec -> deg]
        ra_adj = ra - rot_earth*dt_image;
        dec_adj = dec;                        % No adjustment needed (if polar aligned)
        
        % Store readings - raw
        obj.survey.readings.raw(num_images + 1).mount = obj.readings;
        obj.survey.readings.raw(num_images + 1).timestamps = timestamps;
        
        % Store readings - processed
        obj.survey.readings.processed(num_images + 1).timestamp = proc_timestamp;
        obj.survey.readings.processed(num_images + 1).pos_deg = [ra dec];
        obj.survey.readings.processed(num_images + 1).pos_adj = [ra_adj dec_adj];
        
        msg = 'Took reading.';
%         obj.dmsg([msg, '\n']);
        obj.survey_log(msg);
        
        num_images = num_images + 1;
    end
end