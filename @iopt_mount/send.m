function send(obj, command, process, async)
% General command sending function. 
% 
%     - 'command' can be either a literal command string, or one of the
%       constants defined in the main classdef file. 
% 
%     - 'process' indicates that we expect a response from this command and
%       that we should add it to the command queue and store its start time
%       (for timeout checks).
% 
%     - 'async' indicates that the response will be processed via the standard
%       terminator-mode serial callback funcion. Response must be terminated with
%       '#'. If this is false, the response is processed synchronously by the
%       object's timer callback. 

if nargin < 3
    process = true;
end

if nargin < 4
    async = true;
end

% Send command
% try
fprintf(obj.ser, command);
% catch
%     % If some error occured that trashed the serial object, reinitialize.
%     % This hasn't been tested yet.
%     init_comm();
%     fprintf(obj.ser, command);
% end    
    
if process
    % Add command to command list. If several commands sent, split them, then
    % add commands to the list
    split_commands = strsplit(command, '#');
    command_count = numel(split_commands);
    if command_count > 1
        split_commands = split_commands(1:end-1);       % Last command will be blank, since last char was the delimiter
    end
    
    obj.command_queue = [obj.command_queue, split_commands];
    obj.start_times = [obj.start_times, tic * ones(1, command_count-1, 'uint64')];    % Add start times of each command
    
    if ~async
        obj.sync_hold();
    end
end