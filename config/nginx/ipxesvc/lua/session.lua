local session = {
    init = function(self)
        self._ssid = nil
        self._db = self.storage:deserialize(self.storage:read())
        if self:is_ready() then
            local client_ssid = ngx.var.cookie_PXESSID
            local expiry = tonumber(self._db[client_ssid])
            if expiry and expiry > ngx.time() then
                self._ssid = client_ssid
            end
        end
        return true
    end,
    save = function(self, duration)
        if self:is_ready() then
            self:prune()
            if duration and duration > 0 then
                local ssid = self._ssid or ngx.var.request_id
                self._db[ssid] = ngx.time() + duration
                ngx.header["Set-Cookie"] = 'PXESSID=' .. ssid .. '; Path=/; Expires=' .. ngx.cookie_time(self._db[ssid])
            end
            self.storage:write(self.storage:serialize(self._db))
        end
    end,
    is_ready = function(self)
        return self._db ~= nil
    end,
    get_id = function(self)
        return self._ssid
    end,
    is_valid = function(self)
        return self._ssid ~= nil
    end,
    invalidate = function(self)
        if self._ssid then
            self._db[self._ssid] = 0
            self._ssid = nil
        end
    end,
    get_time_remaining = function(self)
        return self:is_valid() and (self._db[self._ssid] - ngx.time()) or 0
    end,
    prune = function(self)
        local ntbl, now = {}, ngx.time() + 1
        for ssid, expires in pairs(self._db) do
            if expires > now then
                ntbl[ssid] = expires
            end
        end
        self._db = ntbl
    end,
    storage = {
        _path = '/etc/nginx/ipxesvc/lua/session.db',
        set_path = function(self, newpath)
            self._path = newpath
        end,
        get_path = function(self)
            return self._path
        end,
        read = function(self)
            local f = io.open(self._path, 'r')
            if (f == nil) then return '' end
            local data = f:read('*a')
            f:close()
            return data
        end,
        write = function(self, data)
            local f = assert(io.open(self._path, 'w'))
            if (f ~= nil) then
                f:write(data)
                f:close()
                return true
            end
        end,
        serialize = function(self, tbl)
            local entries = {}
            for k, v in pairs(tbl) do
                entries[#entries+1] = k..':'..tostring(v)
            end
            return table.concat(entries, '\r\n')
        end,
        deserialize = function(self, data)
            local tbl = {}
            for entry in string.gmatch(data, '([^\r\n]+)') do
                local k, v = string.match(entry, '(%S+):(%d+)')
                if (k and v) then
                    tbl[k] = tonumber(v)
                end
            end
            return tbl
        end
    }
}
return session
