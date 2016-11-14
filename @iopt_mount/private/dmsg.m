function dmsg(obj, str)
% Print messages only if debug mode is active. This keeps us from having to
% put conditional blocks in the code for each debug message

if obj.debug_mode
    fprintf(str);
end