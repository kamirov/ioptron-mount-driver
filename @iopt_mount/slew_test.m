function slew_test(obj)
% Simple test. Sets a speed, rotates to the west, starts taking readings

obj.set_speed(7);
obj.send_simple(':mw#');
obj.start_readings();