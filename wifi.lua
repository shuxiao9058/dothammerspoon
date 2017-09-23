local wifi = {}

function wifi.toggleWifi()
   local wifiIsPowered = hs.wifi.interfaceDetails('en0')['power']
   if wifiIsPowered then
      hs.wifi.setPower(false)
      hs.notify.new({
            title='Wifi Off',
            informativeText='Wifi is now off'
      }):send()
   else
      hs.wifi.setPower(true)
      hs.notify.new({
            title='Wifi On',
            informativeText='Wifi is now on'
      }):send()
   end
   local wifiIsPowered = nil
end

return wifi
