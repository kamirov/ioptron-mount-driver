function save_readings(obj, clear_after)
% Saves reading structure to a file

if nargin < 2
    clear_after = false;
end

readings = obj.readings;
datetime = datestr(now, 'yyyymmddTHHMMSS');

save(['MountReadings-' datetime], 'readings')

if clear_after
    obj.clear_readings();
end