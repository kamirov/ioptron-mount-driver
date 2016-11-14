function wait_for_slew(obj)
% Waits until the mount is no longer slewing

obj.update_status(0);   % Synchronous status update
while obj.status_back.system == 2
    obj.update_status(0);
end

