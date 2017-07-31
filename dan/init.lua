OSS = 1 -- oversampling setting (0-3)
SDA_PIN = 2 -- sda pin, GPIO2 ovvero il D2 (Bisogna metterlo qua)
SCL_PIN = 3 -- scl pin, GPIO0 ovvero il D3
data={}
--sjson = require("json")
sjson = require('sjson')
--
http = require("http")
gpio.mode(6, gpio.OUTPUT)--D2 pin 
wifi.setmode(wifi.STATION)
wifi.sta.config('CCSAPT9206','ca239ca239')
wifi.sta.connect()
tmr.alarm(1, 5000, 1, function() 
    if wifi.sta.getip()== nil then
        print('IP unavaiable, waiting...') 
    else
        tmr.stop(1)
        print('IP is '..wifi.sta.getip())
    end
end)

gpio.write(6,gpio.HIGH)
port = 80
gpio.mode(1, gpio.OUTPUT)

function getData()
    val = adc.read(0)
  
    print('val: '..tostring(val))
    bmp180 = require("bmp180")
    bmp180.init(SDA_PIN, SCL_PIN)
    bmp180.read(OSS)

    t = bmp180.getTemperature()/10
    p = bmp180.getPressure()/100
    
    
    tf=t*(9/5)+32
  --  print(p)
    print('bmp: '..tostring(tf).. ' F')
   -- print(val)
    tmpc=(((val/1024.0)*3300)-500)*.01
    tmpf=((tmpc*9)/5)+32
   -- print(tmpc)
    print(tmpf)
   
    data['temp']=tmpf
    data['bmpTemp']=tf
    data['pressure']=p
    jsonData=sjson.encode(data)
   -- print(jsonData)
    http.post('http://192.168.1.104:3001/esp',
  'Content-Type: application/json\r\n',
  jsonData,
  function(code, data)
    if (code < 0) then
      print("HTTP request failed")
    else
      print(code, data)
 
      print(code)
      data2=sjson.decode(data)
      print(data2['relay'])
      if(data2['relay']==1) then
      
        gpio.write(6,gpio.HIGH)
 
      else
       gpio.write(6,gpio.LOW)   
      end
    end
  end)
    
    
    --print("Pressure: "..(p * 75 / 10000).."."..((p * 75 % 10000) / 1000).." mmHg")


    -- release module
    --bmp180 = nil
    --package.loaded["bmp180"]=nil 
end
--getData()

--tmr.alarm(1, 1000, tmr.ALARM_AUTO,
tmr.alarm(1, 2000, tmr.ALARM_AUTO, function()
getData()
end)


if srv~=nil then
  srv:close()
end
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
    print(payload) 
--     conn:send("<body><div id='temp'><h1>Temperature in f: "..tostring(tf).."</h1><h1>Pressure: "..tostring(p)..
--     '</h1>'.."<h1> tmp36 sensor in f : "..
--     tostring(tmpf).."</h1></div>"..
--     "<script src='https://code.jquery.com/jquery-1.11.1.js'></script>"..
--     "<script type='text/javascript'>"..
--         "$( document ).ready(){"..
--             "setInterval($('#temp').load(location.href + ' #temp'), 1000);"..
-- "}; </script></body>")
    --conn:send("Content-Type:application/json\n\n")
    conn:send("nodemcu")
    
    conn:close()
    end)
end)

