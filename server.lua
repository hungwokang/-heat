-- Obfuscated Loader (Base64 Encoded Original Script)
local b64 = "LS8vIFNlcnZpY2VzCmxvY2FsIFR3ZWVuU2VydmljZSA9IGdhbWU6R2V0U2VydmljZSgiVHdlZW5TZXJ2aWNlIikKbG9jYWwgUnVuU2VydmljZSA9IGdhbWU6R2V0U2VydmljZSgiUnVuU2VydmljZSIpCmxvY2FsIFBsYXllcnMgPSBnYW1lOkdldFNlcnZpY2UoIlBsYXllcnMiKQpsb2NhbCBMb2NhbFBsYXllciA9IFBsYXllcnMuTG9jYWxQbGF5ZXIKCi0vLyBCeXBhc3MgZm9yIHNpbXVsYXRpb24gb3duZXJzaGlwIChleHBsb2l0IHJlcXVpcmVkKQpsb2NhbCBmdW5jdGlvbiBzZXR1cEJ5cGFzcygpCiAgICBpZiBnZXRnZW52KCkuU2ltUmFkaXVzU2V0ID~=IHRydWUgdGhlbgogICAgICAgIGdldGdlbnYoKS5TaW1SYWRpdXNTZXQgPSB0cnVlCiAgICAgICAgcGNhbGwoZnVuY3Rpb24oKQogICAgICAgICAgICBMb2NhbFBsYXllci5SZXBsaWNhdGlvbkZvdXMgPSB3b3Jrc3BhY2UKICAgICAgICAgICAgc2V0aGlkZGVucHJvcGVydHkoTG9jYWxQbGF5ZXIsICJTaW11bGF0aW9uUmFkaXVzIiwgbWF0aC5odWdlKQogICAgICAgIGVuZCkKICAgIGVuZAoKZW5kCgptb2R1bGUgPSBnZXRnZW52KCkuTmV0d29yaw=="; -- Truncated for brevity; in real output, full base64 string here

-- Simple Base64 Decode Function for Lua (Roblox compatible)
local function base64Decode(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local decoded = base64Decode(b64)
loadstring(decoded)()
