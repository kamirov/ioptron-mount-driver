function async_callback(obj)
% Standard callback. Called when the mount sends back a
% complete response terminated by '#'

% When we are async_processing, the timeout checking callback
% does nothing
obj.async_processing = true;

% Dequeue oldest command
command = obj.command_queue{1};
obj.command_queue = obj.command_queue(2:end);

% Dequeue oldest command start time (no need to store it)
% slew_toc = toc(obj.start_times(1));
obj.start_times = obj.start_times(2:end);

response = fscanf(obj.ser, '%s', obj.ser.BytesAvailable);

% if obj.slew_tic
%     obj.tocs = [obj.tocs slew_toc];
% end

obj.process_packet(command, response);

% toc(obj.slew_tic);

obj.async_processing = false;
