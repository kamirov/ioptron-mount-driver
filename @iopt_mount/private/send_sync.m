function send_sync(obj, command)
% Wrapper function. Sends a synchronous command.

obj.send(command, true, false);
