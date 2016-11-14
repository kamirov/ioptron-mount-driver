function check_timeouts(obj)
% Checks if any commands have been processing for more than the allowable
% time, then checks if there is a response from those commands. If there
% is, processes it. If there isn't, throws a timeout warning.
 
% If we're currently in the async callback, then we don't want timeout
% checking to interfere
if obj.async_processing
    return;
end

for i = 1:numel(obj.start_times)
    
    % Dequeue and get elapsed time
    time = toc(obj.start_times(1));
         
    if time > obj.command_timeout

        obj.start_times = obj.start_times(2:end);
        
        % Dequeue oldest command
        command = obj.command_queue{1};
        obj.command_queue = obj.command_queue(2:end);

        if obj.ser.BytesAvailable
            response = fscanf(obj.ser, '%s', obj.ser.BytesAvailable);
            obj.process_packet(command, response);        
        else
            warning(['Timeout during ' command ' command.']);
        end
    end
       
end