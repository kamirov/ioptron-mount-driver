function survey_log(obj, msg, timestamp)
% Adds a line to the survey log. If no timestamp passed, uses current one

if nargin < 3
    timestamp = datestr(now, 'dd-mmm-yyyy HH:MM:SS.FFF');
end

f = fopen([obj.survey.dir, '/survey.log'], 'a+');
fwrite(f, ['[' timestamp '] ' msg]);
fprintf(f, '\n');
fclose(f);