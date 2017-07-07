wifi.setmode(wifi.STATION)
wifi.sta.config("TTA","thadoe2akhar")
print(wifi.sta.getip())
print(wifi.sta.getmac())

led=2 
gpio.mode(led, gpio.OUTPUT)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1> Esp Web Server</h1>";
        buf = buf.."<p>GPIO2 <a href=\"?pin=ON\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF\"><button>OFF</button></a></p>";
        local _on,_off = "",""
         if(_GET.pin == "ON")then
              gpio.write(led, gpio.HIGH);
         elseif(_GET.pin == "OFF")then
              gpio.write(led, gpio.LOW);
                 end
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
