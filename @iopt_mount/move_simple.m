function move_simple(obj,speed, command)
% Wrapper function. Sends a non-responding command without adding it to the
% queue
obj.set_speed(speed);
obj.send_simple(command);
obj.start_readings();

