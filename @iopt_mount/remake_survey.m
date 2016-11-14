function remake_survey(obj, dir)
% Adds survey data from a folder to the mount object
% 'dir' should be an absolute path (e.g.
% C:\mount_surveys\SkySurvey_20160704T110628_to_20160704T120528)

if strcmp(dir(1:9), 'SkySurvey')
    error('Pass an absolute path (e.g. C:\mount_surveys\SkySurvey_20160704T110628_to_20160704T120528)');
end

if dir(end) == '\' || dir(end) == '/'
    dir = dir(1:end-1);
end

t = [];     % This allows 't' to be overwritten by load(). Otherwise any later 't' references try to call the built-in t() function
load([dir '/survey.mat']);
obj.survey.trajectory = [t, ra, dec];
obj.survey.dir = dir;
obj.survey.ran_atleast_once = ran_atleast_once;