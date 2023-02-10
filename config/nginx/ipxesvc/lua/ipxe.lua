local client_uuid = ngx.var[1]
if (not (client_uuid:find('uuid-') == 1)) then
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end
local ipxe_file_path = '/etc/nginx/ipxesvc/ipxe.conf'
local lines = {}
for line in io.lines(ipxe_file_path) do
    lines[#lines+1] = line
end
local ipxe, uuid = {}, nil
for _, line in ipairs(lines) do
    if line:find('#!ipxe') then
        uuid = line:match('^#!ipxe.*(uuid%-%S+).*') or 'default'
    end
    if (uuid) then
        ipxe[uuid] = ipxe[uuid] or {}
        ipxe[uuid][#ipxe[uuid]+1] = line
    end
end
if (ipxe[client_uuid]) then
    ngx.say(table.concat(ipxe[client_uuid]))
    return ngx.exit(ngx.HTTP_OK)
elseif ipxe['default'] then
    ngx.say(table.concat(ipxe['default']))
    return ngx.exit(ngx.HTTP_OK)
else
    return ngx.exit(ngx.HTTP_NO_CONTENT)
end
-- TODO: dont respond to ips that werent served a bootfile recently, 403
            
        
            

