local client_addr = 'ipv4-'..ngx.var.remote_addr
local client_uuid = ngx.var[1]
if (not (client_uuid:find('uuid-') == 1)) then
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end
local ipxe_file_path = '/userdata/ipxe.conf'
local lines = {}
for line in io.lines(ipxe_file_path) do
    lines[#lines+1] = line
end
local tinsert = table.insert
local ipxe = {}
local script
for _, line in ipairs(lines) do
    if line:find('#!ipxe') == 1 then
        local uuid = line:match('^.*(uuid-%S+).*$') or 'all'
        local ipv4 = line:match('^.*(ipv4-%S+).*$') or 'all'
        script = {} ipxe[ipv4..'.'..uuid] = script
    end
    if (script) then
        tinsert(script, line)
    end
end
script = ipxe[client_addr..'.'..client_uuid]
      or ipxe['all.'..client_uuid]
      or ipxe[client_addr..'.all']
if (script) then
    ngx.say(table.concat(script, '\n'))
    return ngx.exit(ngx.HTTP_OK)
else
    return ngx.exit(ngx.HTTP_NO_CONTENT)
end
