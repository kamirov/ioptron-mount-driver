function move(obj, pos, start_readings, is_ra_dec, in_survey)
% Moves to a given position [RA/Az (deg), dec/al (deg)]

obj.stop_readings();

if nargin < 3 || isempty(start_readings)
    start_readings = false;
end
if nargin < 4 || isempty(is_ra_dec)
    is_ra_dec = true;
end
if nargin < 5 || isempty(in_survey)
    in_survey = false;
end

% Convert az-el coordinates to ra-dec (if needed)
if ~is_ra_dec
    lat = obj.gps(1) / 3600;        % Convert asec->deg
    lon = obj.gps(2) / 3600;
    [ra, dec] = azel2radec(deg2rad(pos(1)), ...
                           deg2rad(pos(2)), ...
                           deg2rad(lat), ...
                           deg2rad(lon), ...
                           local_time_to_utc(now));
    pos(1) = rad2deg(ra);
    pos(2) = rad2deg(dec);
end

ra = pos(1);
dec = pos(2);

if ~in_survey
    obj.dmsg(['Moving to ra-dec: ' num2str(ra) ', ' num2str(dec) ' [deg] \n']);
end

% Get declination and right ascension. Where do these formulas come from?
ra = (ra/15)*(3600*1000);   % Deg to ms
dec = dec*(3600*100);       % Deg to 0.01 asec

% Sanitize
if ra < 0
    error('Right ascension must be positive');
end

% Separate declination into sign and magnitude
if dec >= 0
    sign = '+';
else
    sign = '-';
end
dec = abs(dec);

% Remove any decimals
ra = floor(ra);
dec = floor(dec);

% Build command strings
str_ra = [':Sr', num2str(ra, '%08d'), '#'];
str_dec = [':Sd', sign, num2str(dec, '%08d'), '#'];

% Send commands
obj.send_sync(str_ra)             % Right ascension
obj.send_sync(str_dec)            % Declination
obj.send_sync(':MS#')             % Slew
obj.update_status();

if start_readings
    obj.start_readings();
end

if ~in_survey
    obj.dmsg('\n');
end