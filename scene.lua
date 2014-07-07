local trippedDeviceName = 'Unknown'
local myPayload = ''
local floodThreshold = 10

function doStuff(lul_device, lul_service, lul_variable, lul_value_old, lul_value_new)

    secondsSincelastTrip = os.time() - luup.variable_get("urn:micasaverde-com:serviceId:SecuritySensor1", "LastTrip", lul_device)

    -- luup.log("doStuff: deviceID: "..lul_device..", secondsSincelastTrip:"..secondsSincelastTrip..", lul_variable:"..lul_variable..", lul_value_old:"..lul_value_old..", lul_value_new:"..lul_value_new,25)

    -- within a threshold we're going to consider this the same alert
    -- as certain conditions can lead to a very quick re-trip
    -- Or if we're not tripped of course
    if lul_value_new ~= "1" or secondsSincelastTrip < floodThreshold then
        return "Nothing to do"
    end

    -- Get the device name
    -- @todo surely we can look this up somewhere
    if lul_device == 13 then
        trippedDeviceName = "Lounge outside door"

    elseif lul_device == 14 then
        trippedDeviceName = "Kitchen side door"

    elseif lul_device == 15 then
        trippedDeviceName = "Front door"
    end

    mytime = os.date("%Y-%m-%d %X")

    -- build the payload for the notification service
    myPayload = "message="..trippedDeviceName .. " opened at "..mytime

    luup.log(myPayload,02)

    -- everything else happens in the service device
    luup.call_action("urn:dmlogic-com:serviceId:GenericWebService1", "SendRequest", { Payload=myPayload}, 40)
end

luup.variable_watch("doStuff","urn:micasaverde-com:serviceId:SecuritySensor1","ArmedTripped", 13);
luup.variable_watch("doStuff","urn:micasaverde-com:serviceId:SecuritySensor1","ArmedTripped", 14);
luup.variable_watch("doStuff","urn:micasaverde-com:serviceId:SecuritySensor1","ArmedTripped", 15);

