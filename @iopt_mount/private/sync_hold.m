function sync_hold(obj)
% Wait until all commands in the command queue have been processed.

num = numel(obj.command_queue);

while num
    pause(obj.command_timeout);
    num = numel(obj.command_queue);
end
