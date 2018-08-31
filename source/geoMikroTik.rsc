# Main application file for geoMikroTik project.
# https://github.com/startik/geoMikroTik/
# Copyright: Daniel Starnowski 2018
# Shared under the MIT License

# splitFileLines - function creating array of non-empty lines from the file
# Example: :local fileLinesArray [$splitFileLines "disk1/example.txt"]
:local splitFileLines do={
  :local file [/file get "$1" contents];
  :local fileLines [:toarr ""];
  :local filePosition 0;
  :local endFile 0;
  while ($endFile<1) do={
    :local nextNF [:find $file "\n" $filePosition]
    :if ([:typeof $nextNF]="nil") do={
      :set $endFile 1;
    } else={
     :if (($nextNF-$filePosition)>1) do={
        :set $fileLines ($fileLines,[:pick $file $filePosition $nextNF]);
      }
      :set $filePosition ($nextNF+1);
    }
  }
  :return $fileLines;
}

# prepareJSON - function creating the JSON request data for Google Geolocation API from the array of wireless scan lines
# Example: :local http-data [$prepareJSON $fileLinesArray]
:local prepareJSON do={
  :local request "{\"wifiAccessPoints\":[";
  :local firstLine 1;
  :foreach line in=$1 do={
    :local s1 [:find $line ",'"];
    :local s2 [:find $line "'," $s1];
    :local s3 [:find $line "," ($s2+1)];
    :local s4 [:find $line "," $s3];
    :local macAddr [:pick $line 0 $s1];
    :local signal [:pick $line ($s3+1) $s4];
    :if ($firstLine<1) do={
      :set $request ($request . ",");
    } else={
      :set $firstLine 0;
    }
    :set $request ($request . "{\"macAddress\":\"$macAddr\",\"signalStrength\":\"$signal\"}");
  }
  :set $request ($request . "]}");
  :return $request;
}

# Initialize table for AP list
:local apList [:toarr ""];

# Run wireless scan on all wireless interfaces and store results in separate array lines
:foreach wifiInterface in=[/interface wireless find] do={
  :local fileName ("geoMikroTik-" . [/interface wireless get $wifiInterface name] . ".scan");
  /interface wireless scan $wifiInterface duration=10s save-file="$fileName";
  :delay 2s;
  :set $apList ($apList,[$splitFileLines $fileName]);
  /file remove $fileName;
}
# Prepare the Google API JSON request
:local httpData [$prepareJSON $apList];
:put $httpData;
