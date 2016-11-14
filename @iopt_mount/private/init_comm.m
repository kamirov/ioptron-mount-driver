function init_comm(obj, com_port)
% Initialize com port, clear old port, establish connection with mount

if nargin < 2
    com_port = obj.port;
    reinit = true;
else
    reinit = false;
end

if reinit
    obj.dmsg('Communication lost. Reinitializing...');
else
    obj.dmsg('Initializing communication...');
end

obj.port = com_port;

% Make sure platform is inactive
active = instrfind('Port', com_port);
if ~isempty(active)
    fclose(active);
    delete(active);
end

% Setup port
obj.ser = serial(com_port, 'Terminator', '#', 'BaudRate', obj.baud_rate);
obj.ser.BytesAvailableFcn = @(ser, event)(obj.async_callback());
fopen(obj.ser);

% Clear buffer
if obj.ser.BytesAvailable > 0
    obj.dmsg('Bytes still available on the serial port. Flushing... ');
    fscanf(obj.ser, '%s', obj.ser.BytesAvailable);
end

obj.dmsg('Done!\n');