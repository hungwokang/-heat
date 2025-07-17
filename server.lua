local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function d(s)local e,c,o=string.byte,table.concat,{}for i=1,#s,4 do local a,b,c,d=e(s,i,i),e(s,i+1,i+1),e(s,i+2,i+2),e(s,i+3,i+3)o[#o+1]=string.char(((a-1)%64)*4+(math.floor((b or 1)-1)/16)%4*64+(math.floor((c or 1)-1)/4)%16)end;return c(o)end
loadstring(d("CmxvY2FsIFBsYXllcnMgPSBnYW1lOkdldFNlcnZpY2UoIlBsYXllcnMiKQpsb2NhbCBSdW5TZXJ2aWNlID0gZ2FtZTpHZXRTZXJ2aWNlKCJSdW5TZXJ2aWNlIikKbG9jYWwgV29ya3NwYWNlID0gZ2FtZTpHZXRTZXJ2aWNlKCJXb3Jrc3BhY2UiKQotLSAocmVzdCBvZiB0aGUgc2NyaXB0IG5vdCBzaG93biBmb3IgYnJldml0eSkK"))()
