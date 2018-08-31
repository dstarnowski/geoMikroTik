# Main application file for geoMikroTik project.
# https://github.com/startik/geoMikroTik/
# Copyright: Daniel Starnowski 2018
# Shared under the MIT License

# Put your Google Geolocation API key here:
:local apiKey "XXXXXXXX";

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

# getGoogleLocation - function getting Latitude, Longitude and Accuracy data from the Google Geolocation API response (array of lines)
# response is in form of array with keys: lat, lon, acc and valid (valid=0 - no position, valid=1 - position found)
# Example: :if (([$getGoogleLocation $fileLocationArray]->"valid")>0) {:local accuracy [$getGoogleLocation "fileLocation.txt"]->"acc";}
:local getGoogleLocation do={
  :local valid 0;
  :local lat 0;
  :local lon 0;
  :local acc 0;
  :foreach line in=$1 do={
    :if ([:find $line "\"lat\":"]!="nil") do={
      :set $valid ($valid+1);
      :set $lat [:pick $line ([:find $line "\"lat\":"]+7) [:find $line " " ([:find $line "\"lat\":"]+7)]];
    }
    :if ([:find $line "\"lng\":"]!="nil") do={
      :set $valid ($valid+1);
      :set $lon [:pick $line ([:find $line "\"lng\":"]+7) [:len $line]];
    }
    :if ([:find $line "\"accuracy\":"]!="nil") do={
      :set $valid ($valid+1);
      :set $acc [:pick $line ([:find $line "\"accuracy\":"]+12) [:len $line]];
    }
  }
  :if ($valid<3) do={
    :return {valid=0};
  } else={
    :return {valid=1;lat="$lat";lon="$lon";acc="$acc"};
  }
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

# Prepare and send the Google API JSON request
:local httpData [$prepareJSON $apList];
:put $httpData;
/tool fetch url="https://www.googleapis.com/geolocation/v1/geolocate\?key=$apiKey" http-content-type="application/json" http-method=post http-data="$httpData" dst-path="locationFile.txt";
:delay 2s;

# Parse the results
:local locationFile [$splitFileLines "locationFile.txt"];
:local result [$getGoogleLocation $locationFile];
:put "";
:put "";
:put "";
:if (($result->"valid")>0) do={
  :local lat ($result->"lat");
  :local lon ($result->"lon");
  :local acc ($result->"acc");
  :put "Coordinates found:"
  :put "Latitude: $lat";
  :put "Longitude: $lon";
  :put "Acuracy: $acc";
  :put "Direct Google Maps link:";
  :put "https://www.google.com/maps/\?q=$lat,$lon";
} else={
  :put "Unfortunately, couldn't get location.";
}
