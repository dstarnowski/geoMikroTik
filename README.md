# geoMikroTik
MikroTik script to geolocate the device with just WiFi.

What is needed: Any MikroTik device with RouterOS system and a WiFi card.

Usage:
1. Obtain the Google API Key for Geolocation API:
https://developers.google.com/maps/documentation/geolocation/get-api-key

2. Enter the key in the file instead of the XXXXXXXX:
```
:local apiKey "XXXXXXXX";
```

Alternatively:
3a. Upload the file to your MikroTik router
4a. Run the script with:
```
/import "geoMikroTik.rsc"
```

Or:
3b. Create a script on MikroTik router called "geoMikroTik" and paste the script code
4b. Run the script with:
```
/system script run geoMikroTik
```

The results should look like:
```
Coordinates found:
Latitude: 56.9378815
Longitude: 24.0401126
Accuracy: 40.0
Direct Google Maps link:
https://www.google.com/maps/?q=56.9378815,24.0401126
```
