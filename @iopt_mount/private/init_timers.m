function init_timers(obj)
% Initializes the timeout and processing timers

obj.dmsg('Initializing timers...');

% Create and start timeout timer
obj.timeout_timer = timer;
obj.timeout_timer.Name = 'Timeout Timer';
obj.timeout_timer.Period = obj.command_timeout / 2;
obj.timeout_timer.TasksToExecute = inf;
obj.timeout_timer.ExecutionMode = 'fixedRate';
obj.timeout_timer.TimerFcn = @(src, event) obj.check_timeouts;
start(obj.timeout_timer);

% Create processing timer (don't start)
obj.process_timer = timer;
obj.process_timer.Name = 'Process Timer';
obj.process_timer.TasksToExecute = inf;
obj.process_timer.ExecutionMode = 'fixedRate';
obj.process_timer.TimerFcn = @(src, event) obj.take_readings;

obj.dmsg('Done!\n');