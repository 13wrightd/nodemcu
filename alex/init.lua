wifi.setmode(wifi.STATION)
wifi.sta.config("TTA","thadoe2akhar") --SSID and password
print(wifi.sta.getip())
print(wifi.sta.getmac())

led=2 
gpio.mode(led, gpio.OUTPUT)--D2 pin 

V=adc.read(0)     --Vout from Lm19 temperature sensor
a=(2.1962*1000000)+((1.8639-V)/(3.88*.0000001)) --converting Vout to temperature value lm19
T=math.sqrt(a)-1481.96
print(V)
print(T)
t=tostring(T) --to print value on html

if srv~=nil then
  srv:close()
end

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
        buf = buf.."<p>Led at D2 <a href=\"?pin=ON\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF\"><button>OFF</button></a></p>";
        buf = buf.."<h2> temperature in C is "..t.."</h2>";
        
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
