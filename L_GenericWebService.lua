local http = require 'socket.http'
local deviceSettings = {}
local deviceSID = 'urn:dmlogic-com:serviceId:GenericWebService1'

-- Builds the request and sends off to our service
function SendRequest(lul_device, lul_settings)

    local response_body = { }
    local payload = deviceSettings.Payload .. "&"..lul_settings.Payload

    local res, code, response_headers = socket.http.request
    {

      url = deviceSettings.ServiceUrl;
      method = deviceSettings.Method;
      headers =
      {
        ["Content-Type"] = "application/x-www-form-urlencoded";
        ["Content-Length"] = #payload;
      };
      source = ltn12.source.string(payload);
      sink = ltn12.sink.table(respsonse_body);
    }

end

-- Hat tip to the SMTP plugin for gettings vars like this
function gwsReadVariable(lul_device, devicetype, name, defaultValue)

    local var = luup.variable_get(devicetype,name, lul_device)

    if (var == nil) then
        var = defaultValue
        luup.variable_set(devicetype,name,var,lul_device)
    end

    -- watch for those ampersands run through the UIs
    var = string.gsub(var,"&amp;","&")

    return var

end

-- Read in our settings variables. As at v1.0 there is no convenience interface
-- to enter these into Vera. Instead add them as custom variables in the
-- Advanced tab using:
--     urn:dmlogic-com:serviceId:GenericWebService1
-- as the "New Service" identifier
function gwsStartup(lul_device)

    luup.task("Running Lua Startup", 1, "GenericWebService", -1)

    deviceSettings.ServiceUrl = gwsReadVariable(lul_device,deviceSID,"ServiceUrl","http://requestb.in/ppw34epp")
    deviceSettings.Method     = gwsReadVariable(lul_device,deviceSID,"Method","POST")
    deviceSettings.Payload    = gwsReadVariable(lul_device,deviceSID,"Payload","empty")
end
