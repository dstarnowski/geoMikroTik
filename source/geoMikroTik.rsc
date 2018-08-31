# Main application file for geoMikroTik project.
# https://github.com/startik/geoMikroTik/
# Copyright: Daniel Starnowski 2018
# Shared under the MIT License

# Initialize table for AP list
:local apList [:toarr ""];

# Run wireless scan on all wireless interfaces
:foreach wifiInterface in=[/interface wireless find] do={
  :local fileName ("geoMikroTik-" . [/interface wireless get $wifiInterface name] . ".scan");
  /interface wireless scan $wifiInterface duration=10s save-file="$fileName";
  :delay 1s;
}
