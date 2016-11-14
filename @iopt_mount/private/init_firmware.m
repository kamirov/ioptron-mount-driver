function init_firmware(obj)
% Sends initialization commands to mount

obj.dmsg('Initializing firmware...');

obj.send_sync(':V#');           % Initialize
obj.send_sync(':MountInfo#');   % Get mount info
% obj.send_sync(':CM#');          % Calibrate

obj.dmsg('Done!\n');