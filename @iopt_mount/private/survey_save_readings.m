function survey_save_readings(obj, traj_idx)
% Stops taking readings, saves current point's data, then clears on-board
% readings

obj.stop_readings();

raw = obj.survey.readings.raw;
processed = obj.survey.readings.processed;

num_readings = numel(raw);
if num_readings == 1
    readings_str = '1 reading';
else
    readings_str = [num2str(num_readings) ' readings'];
end

readings_file = ['Point' sprintf('%03d', traj_idx) 'Readings.mat'];
reading_path = [obj.survey.dir '/' readings_file];
save(reading_path, 'raw', 'processed');
obj.survey_log([readings_str ' saved to ' readings_file '.']);

obj.clear_readings();