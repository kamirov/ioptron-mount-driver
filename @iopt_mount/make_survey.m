function make_survey(obj, el_min, t_test, fov, lat, lon, store_survey, parent_dir)
% Generates sky survey. Stores resulting trajectory on the object
%     
% Inputs:
%     - el_min          Minimum elevation [deg]
%     - t_test          Test time [min]
%     - fov             Field of view (half-cone) [deg]
%     - lat             Latitude [deg]
%     - lon             Longitude [deg]
%     - store_survey    Boolean. If true, generates log file and stores
%                       traj on object
% Notes:
%     - This requires sky_survey.m and its dependencies to be on the PATH (see https://github.com/kamirov/matlab-sky-survey)

if nargin < 8
    parent_dir = pwd;    % Current dir
end

if nargin < 7
    % Test values (for debugging)
    el_min = 60;
    t_test = 15;
    fov = 7.5;
    lat = 43;
    lon = -79;
    store_survey = true;
end

% Change these if you want to see some sky survey plots
show_plots = true;
show_elevation_profiles = false;
fig_idx = 100;      % For main plot (not elevation profiles). The actual index is irrelevant, so long as it's not used elsewhere

% These values can be adjusted if you'd like to see some variants of the
% sky survey
tuning = struct('prioritize_high_elevations', true, ...
            'timing', ...
                struct('adjust', true, ...
                       'min_step', 1), ...
            'proximity', ...
                struct('adjust', true, ...
                      'window_cost_threshold', 0.3, ...
                      'window_max_size', 10, ...
                      'ra_weight', 1, ...
                      'dec_weight', 1));

[t, ra, dec, fig] = sky_survey(el_min, t_test, fov, lat, lon, tuning, fig_idx, show_elevation_profiles);

if store_survey
    obj.survey.trajectory = [t, ra, dec];
    ran_atleast_once = false;
    obj.survey.ran_atleast_once = ran_atleast_once;
    
    % Sky survey folder
    start_time = datestr(t(1,:), obj.date_fmt);
    end_time = datestr(t(end,:), obj.date_fmt);
    obj.survey.dir = [parent_dir '\SkySurvey_' start_time '_to_' end_time];
    mkdir(obj.survey.dir);
    
    % Log
    log_file = fopen([obj.survey.dir '/survey.log'], 'w');
    fclose(log_file);
    obj.survey_log(['Generated survey (' num2str(numel(ra)) ' points, ' datestr(t(1,:)) ' to ' datestr(t(end,:)) ').']);
    
    % Parameters
%     param_file = [obj.survey.dir '/params.txt'];
%     params = {'- Survey Parameters - ', ''
%               'Name: ', obj.survey.dir
%               'Start time: ', datestr(t(1,:))
%               'End time: ', datestr(t(end,:))
%               'Test duration: ', [num2str(t_test) ' mins']
%               'Latitude: ', [num2str(lat) ' deg']
%               'Longitude: ', [num2str(lon) ' deg']
%               'Min elevation: ', [num2str(el_min) ' deg']
%               'Field of view: ', [num2str(fov) ' deg (half-cone)']};
%     params = [char(params{:,1}), char(params{:,2})];
%     dlmwrite(param_file, params, 'Delimiter', '');
    
    % Survey parameters
    param_file = [obj.survey.dir '/survey.mat'];
    save(param_file, 't', 'ra', 'dec', 't_test', 'lat', 'lon', 'el_min', 'fov', 'ran_atleast_once');
    
    % Survey plot
    fig_file = [obj.survey.dir '/survey.fig'];
    savefig(fig, fig_file);
    if ~show_plots
        close(fig);
    end
end