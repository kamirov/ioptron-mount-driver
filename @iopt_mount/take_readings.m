function take_readings(obj)
% Takes position, time, and GPS readings. Sends one long multi-command
% string to be asynchronously processed.

% obj.slew_tic = tic;
% Read position, time, latitude, longitude
obj.send(':GEC#:GLT#:Gt#:Gg#');