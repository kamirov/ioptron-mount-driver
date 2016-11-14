function send_simple(obj, command)
% Wrapper function. Sends a non-responding command without adding it to the
% queue

obj.send(command, false);
