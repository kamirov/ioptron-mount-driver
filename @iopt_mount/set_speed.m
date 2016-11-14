function set_speed(obj, speed)
% Sets slewing rate. Speed should be 1-9, where 1 stands for 1x sidereal
% tracking rate, 2 stands for 2x, 3 stands for 8x, 4 stands for 16x, 5
% stands for 64x, 6 stands for 128x, 7 stands for 256x, 8 stands for 512x,
% 9 stands for maximum speed

if speed < 0
    speed = 0;
elseif speed > 9
    speed = 9;
end

command = [':SR', num2str(speed), '#'];
obj.send_sync(command);