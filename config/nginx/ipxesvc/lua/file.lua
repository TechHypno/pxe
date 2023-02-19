local client_addr = ngx.var.remote_addr
local client_requested_file = ngx.var[1]

local files_dir = '/etc/nginx/ipxesvc/files'
local file_path = files_dir..'/'..client_requested_file

-- local pfile = io.popen('ls"'..file_path..'"')
-- for filename in pfile:lines() do
--     ngx.say(filename..'\n')
-- end
-- pfile:close()

local file = io.open(file_path, 'r')
if (not file) then
    return ngx.exit(ngx.HTTP_NO_CONTENT)
end
ngx.say(file:read('*a'))
file:close()
