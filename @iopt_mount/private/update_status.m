function update_status(obj, async)

if nargin < 2
    async = 1;
else
    async = 0;
end

obj.send(':GAS#', 1, async);