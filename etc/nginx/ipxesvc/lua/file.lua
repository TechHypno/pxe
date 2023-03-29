local client_addr = ngx.var.remote_addr
local client_requested_file = ngx.var[1]

local files_dir = '/userdata/files'
local file_path = files_dir..'/'..client_requested_file

local file = io.open(file_path, 'r')
if (not file) then
    return ngx.exit(ngx.HTTP_NO_CONTENT)
end
ngx.say(file:read('*a'))
file:close()
