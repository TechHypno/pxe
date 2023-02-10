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
    html, body, section, form {
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
local editor = [[
<div class="margin-h-10">
    <div class="left">
        <a class="button rounded-small" style="margin-top: 10px" href="https://ipxe.org/cmd" target="_blank">iPXE Commands</a>
    </div>
    <div class="right">
        <form action="/" method="post">
            <input hidden name="action" value="signout"/>
            <button class="rounded-small" type="sumbit">Sign out</button>
        </form>
    </div>
</div>
<div class="full-height margin-h-10 rounded-large">
    <form action="/" method="post">
        <input hidden name="action" value="save"/>
        <textarea class="editor full-width" id="editor" spellcheck="false" name="ipxe">{ipxe}</textarea>
        <button class="margin-v-10 rounded-small" type="sumbit">Save</button>
    </form>
</div>
]]


package.path = '/etc/nginx/ipxesvc/lua/?.lua;'..package.path
local ipxe_file_path = '/etc/nginx/ipxesvc/ipxe.conf'

local session = require('session')
local is_logged_in = session:init() and session:is_valid()

local output

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

if is_logged_in then
    if post.action == 'save' then
        local ipxe_file = assert(io.open(ipxe_file_path, 'w'))
        ipxe_file:write(post.ipxe)
        ipxe_file:close()
        output = string.gsub(string.gsub(template, '{content}', editor, 1), '{ipxe}', post.ipxe, 1)
    else
        local ipxe_file = assert(io.open(ipxe_file_path, 'r'))
        output = string.gsub(string.gsub(template, '{content}', editor, 1), '{ipxe}', ipxe_file:read('*a'), 1)
        ipxe_file:close()
    end
    
    session:save(((post.remember == 'on') or (session:get_time_remaining() > 3600)) and (3600 * 24 * 7) or 3600)
else
    output = string.gsub(template, '{content}', signin, 1)
    session:save()
end

if output then
    ngx.say(output)
end