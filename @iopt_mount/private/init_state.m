function init_state(obj)
% Initializes mount position, coordinates, and time. Also sets mount speed
% to maximum.

obj.dmsg('Initializing state...');
obj.send_sync(':GEC#');
obj.send_sync(':GLT#');
obj.send_sync(':Gt#');
obj.send_sync(':Gg#');
obj.set_speed(9);
obj.clear_readings();

% Update status
obj.send_sync(':GAS#');

obj.dmsg('Done!\n');
