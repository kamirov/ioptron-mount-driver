function stop(obj)
% Stops reading and slewing

obj.stop_readings();
obj.send_sync(':q#');