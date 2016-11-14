function start_readings(obj, timer_period)
% Starts updating position, GPS, and datetime readings every timer_period
% seconds. Periods less than 0.5s are unstable.

% In case it was already running
stop(obj.process_timer);

if nargin < 2
    timer_period = 0.5;     % Arbitrary
end

obj.process_timer.Period = timer_period;
start(obj.process_timer);