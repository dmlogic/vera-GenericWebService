Generic web service plugin for Vera home automation controllers
===============================================================

This plugin enables submissions to any web service that uses a REST style HTTP interface. This may include email or SMS notifications, custom logging or analytics, social media APIs or other home automation controllers.

The plugin allows you to specify service URL, submission method and a payload. The latter would normally be a query string such as 

    event=door-opened&door=front-door

## Usage

### Installation

Download or clone this repo, then upload all files except this one and the scene.lua example to your Vera as normal. In UI5 this is via Apps > Develop Apps > Luup files.

Create a new device via Apps > Develop Apps > Create device. Give the device a Description, set Upnp Device Filename to `D_GenericWebService.xml` and Upnp Implementation Filename to `I_GenericWebService.xml`.

### Device configuration

Each device should have three variables set: `ServiceUrl`, `Method` and `Payload`. At present there is no custom interface for setting these variables so it must be done via the "Advanced" tab of the device settings. It's a little fiddly but not complex:

* Set `New service:` to `urn:dmlogic-com:serviceId:GenericWebService1`
* Set `New variable:` to the name of the variable to set
* Set `New value` to the value for this variable
* Repeat for each variable, then close the device and Save changes.
* The `Payload` variable should contain any required information such as username and password. It can be added to when the device is called (see below)

The device can then be called from via luup as follows:

    luup.call_action("urn:dmlogic-com:serviceId:GenericWebService1", "SendRequest", { Payload=YOUR_PAYLOAD}, DEVICE_ID)

Where `YOUR_PAYLOAD` is anything in addition to the default payload for the device and `DEVICE_ID` is the unique ID for the device in question.

## Example - SMS notifications for door sensors

This plugin was developed in frustration at the (understandably) tiny limitations on Vera SMS notifications for UK customers. I use it to send an SMS to my phone in the event a [door sensor](http://www.vesternet.com/z-wave-vision-door-window-sensor) is tripped when armed.

This can be done as follows:

1. Sign up to a SMS provider and purchase some credits. I'm finding [TextMarketer](http://www.textmarketer.co.uk/) is working well.
2. Install a GenericWebService device as described above
3. Set the `ServiceUrl` to `https://api.textmarketer.co.uk/services/rest/sms`
4. Set the `Method` variable to `POST`
5. Set the `Payload` variable to the required information for TextMarketer, e.g. `username=XXX&password=YYY&mobile_number=441234567890&originator=YourHouse`
6. Create two Scenes, one called "Arm doors" and one called "Disarm doors". Add your sensors to each Scene and set them Arm/Bypass as appropriate
7. Add some LUUP to the "Arm doors" scene to monitor the `ArmedTripped` variable for each device. This code will need to be changed to suit your setup but mine looks like [this](scene.lua). The end goal is to add `message=something` to the payload
8. Save your Lua, confirm changes and Save Vera. The scene will need restarting after each Vera reload.

