local template = [[
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>iPXE</title>
    <style>
    * {
        box-sizing: border-box;
    }
    html, body, section {
        background-color: #242f40;
        max-width: 1900px;
        height: 100%;
    }
    section {
        height: 100%;
    }
    .loginbox {
        background-color: #eaf1ff;
        position: fixed;
        width: 300px;
        height: 146px;
        top: 50%;
        left: 50%;
        margin-left: -150px;
        margin-top: -73px;
        padding: 15px;
    }
    .checkbox {
        margin: 0px;
    }
    .textfield {
        border-width: 1;
        width: 100%;
        padding: 5px;
    }
    .textfield:focus {
        border-width: 1;
    }
    .full-width {
        width: 100%;
    }
    .full-height {
        height: 100%;
    }
    .editor {
        background-color: #293134;
        color: #6ad0ef;
        vertical-align: top;
        resize: none;
        padding: 15px;
        height: 80%;
    }
    .rounded-large {
        border-radius: 9px;
    }
    .rounded-small {
        border-radius: 3px;
    }
    .margin-v-10 {
        margin-top: 10px;
        margin-bottom: 10px;
    }
    .margin-h-10 {
        margin-left: 10px;
        margin-right: 10px;
    }
    .right {
        float: right;
    }
    .left {
        float: left;
    }
    a.button {
        display: inline-block;
        text-decoration: none;
        width: 100%;
        vertical-align: middle;
        border-width: 0;
        background-color: #aaccff;
        padding: 0px 5px;
        font-family: Arial;
        font-size: 16px;
        font-weight: bold;
        margin-bottom: 5px;
        height: 28px;
        line-height: 28px;
        cursor: pointer;
    }
    button {
        display: inline-block;
        text-decoration: none;
        width: 100%;
        border-width: 0;
        background-color: #aaccff;
        font-family: Arial;
        font-size: 16px;
        font-weight: bold;
        margin-top: 10px;
        padding: 0px 5px;
        height: 28px;
        cursor: pointer;
    }
    a.button:hover {
        background-color: #88b8ff;
    }
    button:hover {
        background-color: #88b8ff;
    }
    </style>
</head>
<body>
    <script>
    function sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
    async function cpy(id)
    {
        if (window.getSelection) {
            var t = document.getElementById(id)
            var ra = document.createRange();
            var sl = window.getSelection();
            ra.selectNodeContents(t);
            sl.removeAllRanges();
            sl.addRange(ra);
            document.execCommand("copy")
            var temp = t.textContent
            t.textContent = "Copied."
            await sleep(1500)
            t.textContent = temp
        }
    }
    </script>
    <section>
        {content}
    </section>
</body>
</html>
]]
local signin = [[
<form action="/" method="post">
    <div class="loginbox rounded-large">
        <input hidden name="action" value="signin"/>
        <input class="textfield rounded-small margin-v-10" type="password" id="password" name="password" placeholder="Password" autofocus/>
        <input class="checkbox" type="checkbox" id="remember" name="remember"/>
        <label class="textfield" for="remember">Remember me</label>
        <button class="margin-v-10 button rounded-small" type="sumbit">Sign in</button>
    </div>
</form>
]]
local links = {
    ipxehelp = [[
    <div class="left">
        <a class="button rounded-small" style="margin-top: 10px" href="https://ipxe.org/cmd" target="_blank">iPXE Commands</a>
    </div>
]],
    mainscript = [[
        <div class="left">
            <a class="button rounded-small" style="margin-top: 10px" href="/">Main Script</a>
        </div>
]],
    directory = [[
        <div class="left" style="width: 80px; margin-left: 10px">
            <form action="/" method="post">
                <input hidden name="action" value="list"/>
                <button class="rounded-small" type="sumbit">Files</button>
            </form>
        </div>
]]
}
local editor = [[
<div class="margin-h-10">
    {link1}
    {link2}
    <div class="right">
        <form action="/" method="post">
            <input hidden name="action" value="signout"/>
            <button class="rounded-small" type="sumbit">Sign out</button>
        </form>
    </div>
</div>
<div class="full-height margin-h-10 rounded-large">
    <form action="/" method="post" style="height: 100%%">
        <input hidden name="action" value="save"/>
        <input hidden name="file" value="{file}"/>
        <textarea class="editor full-width" id="editor" spellcheck="false" name="text">{text}</textarea>
        <button class="margin-v-10 rounded-small" type="sumbit">Save</button>
    </form>
</div>
]]
local filelistelement = [[
<button class="rounded-small left" style="width:28px" onClick="cpy('{file}')">📋</button>
<form action="/" method="post">
    <input hidden name="action" value=""/>
    <input hidden name="file" value="{file}"/>
    <button class="rounded-small left" style="width:320px" id="{file}" type="sumbit">{label}</button>
</form>
<form action="/" method="post">
    <input hidden name="action" value="delete"/>
    <input hidden name="file" value="{file}"/>
    <button class="rounded-small left" style="width:28px;color:#F0F0F0;background-color:#F00000" type="sumbit">X</button>
</form>
]]
local directory = [[
<div class="margin-h-10">
    {link1}
    {link2}
    <div class="right">
        <form action="/" method="post">
            <input hidden name="action" value="signout"/>
            <button class="rounded-small" type="sumbit">Sign out</button>
        </form>
    </div>
</div>
<div class="full-height margin-h-10 rounded-large" style="padding-top: 50px">
    {list}
    <form action="/" method="post">
    <input hidden name="action" value="new"/>
    <button class="margin-v-10 rounded-small" style="width: 320px; clear:left; margin-left: 28px" type="sumbit">New</button>
    </form>
</div>
]]



package.path = '/etc/nginx/ipxesvc/lua/?.lua;'..package.path
local ipxe_file_path = '/userdata/ipxe.conf'
local other_files_dir = '/userdata/files'

local session = require('session')
local is_logged_in = session:init() and session:is_valid()

local output = template

local post = {}
if ngx.req.get_method() == 'POST' then
    ngx.req.read_body()
    post = ngx.req.get_post_args()
end

if post.action == 'signin' then
    local password = os.getenv('PXE_PASSWORD') or 'password'
    assert(password:len() > 0, 'error: empty password')
    if post.password == os.getenv('PXE_PASSWORD') then
        is_logged_in = true
    else
        ngx.sleep(1)
    end
elseif post.action == 'signout' then
    is_logged_in = false
    session:invalidate()
end

local function ShowList()
    local list = {}
    local pfile = io.popen('ls "'..other_files_dir..'"')
    for filename in pfile:lines() do
        local button = filelistelement
        button = button:gsub('{file}', filename)
        button = button:gsub('{label}', filename, 1)
        list[#list + 1] = button
    end
    pfile:close()
    output = output:gsub('{content}', directory, 1)
    output = output:gsub('{link1}', links.mainscript, 1)
    output = output:gsub('{link2}', links.directory, 1)
    output = output:gsub('{list}', table.concat(list, "\n"), 1)
end

if is_logged_in then
    if (post.action == 'save') then
        if (post.file == 'ipxe') then
            local ipxe_file = assert(io.open(ipxe_file_path, 'w'))
            ipxe_file:write(post.text)
            ipxe_file:close()
            output = output:gsub('{content}', editor, 1)
            output = output:gsub('{link1}', links.ipxehelp, 1)
            output = output:gsub('{link2}', links.directory, 1)
            output = output:gsub('{file}', 'ipxe', 1)
            output = output:gsub('{text}', post.text, 1)
        elseif (post.file:find('/') == nil) then
            local other_file = assert(io.open(other_files_dir..'/'..post.file, 'r'))
            other_file:close()
            other_file = assert(io.open(other_files_dir..'/'..post.file, 'w'))
            other_file:write(post.text)
            other_file:close()
            ShowList()
        end
    elseif (post.action == 'list') then
        ShowList()
    elseif (post.action == 'new') then
        local charset = {}  do
            for c = 48, 57  do table.insert(charset, string.char(c)) end
            for c = 65, 90  do table.insert(charset, string.char(c)) end
            for c = 97, 122 do table.insert(charset, string.char(c)) end
        end
        local function randomString(length)
            if not length or length <= 0 then return '' end
            math.randomseed(os.clock()^5)
            return randomString(length - 1) .. charset[math.random(1, #charset)]
        end
        local filename = randomString(32)
        local file = assert(io.open(other_files_dir..'/'..filename, 'w'))
        file:write('')
        file:close()
        output = output:gsub('{content}', editor, 1)
        output = output:gsub('{link1}', links.mainscript, 1)
        output = output:gsub('{link2}', links.directory, 1)
        output = output:gsub('{file}', filename, 1)
        output = output:gsub('{text}', '', 1)
    elseif (post.action == 'delete') then
        if (post.file and post.file:find('/') == nil) then
            local pfile = io.popen('rm -f "'..other_files_dir..'/'..post.file..'"')
            pfile:close()
        end
        ShowList()
    else
        if (post.file and post.file:find('/') == nil) then
            local file = assert(io.open(other_files_dir..'/'..post.file, 'r'))
            output = output:gsub('{content}', editor, 1)
            output = output:gsub('{link1}', links.mainscript, 1)
            output = output:gsub('{link2}', links.directory, 1)
            output = output:gsub('{file}', post.file, 1)
            output = output:gsub('{text}', file:read('*a'), 1)
            file:close()
        else
            local file = assert(io.open(ipxe_file_path, 'r'))
            output = output:gsub('{content}', editor, 1)
            output = output:gsub('{link1}', links.ipxehelp, 1)
            output = output:gsub('{link2}', links.directory, 1)
            output = output:gsub('{file}', 'ipxe', 1)
            output = output:gsub('{text}', file:read('*a'), 1)
            file:close()
        end
    end
    
    session:save(((post.remember == 'on') or (session:get_time_remaining() > 3600)) and (3600 * 24 * 7) or 3600)
else
    output = string.gsub(template, '{content}', signin, 1)
    session:save()
end

if output then
    ngx.say(output)
end