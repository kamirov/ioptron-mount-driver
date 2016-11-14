function confirm_dependencies(obj)
% Confirms necessary utility scripts are on the PATH. If can't find them,
% kerfuffles

obj.dmsg('Confirming dependencies...');

% Add mount folder to path (if needed)
path_cell = regexp(path, pathsep, 'split');
if ~any(strcmpi(obj.dir, path_cell))
    addpath(genpath(obj.dir));
end

% This would not be necessary if all deps were packaged with the class
% Where is a MATLAB package manager when you need it (note to self, make one)
deps = {'azel2radec'
        'local_time_to_utc'
        'radec2azel'
        'sky_survey'};    
for i = 1:numel(deps)
    if ~exist(deps{i})
        error(['Missing dependency. Add ' deps{i} '() to the path.']);
    end
end

obj.dmsg('Done!\n');