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
    :if ([:typeof $nexNF]="nil") do={
      :set $endFile 1;
    } else={
      :if (($nextNF-$filePosition)>1) do={
        :set $fileLines ($filelines,[:pick $file $filePosition $nextNF]);
      }
      :set $filePosition ($nextNF+1);
    }
  }
  :return $fileLines;
}

# Initialize table for AP list
:local apList [:toarr ""];

# Run wireless scan on all wireless interfaces
:foreach wifiInterface in=[/interface wireless find] do={
  :local fileName ("geoMikroTik-" . [/interface wireless get $wifiInterface name] . ".scan");
  /interface wireless scan $wifiInterface duration=10s save-file="$fileName";
  :delay 1s;
  :set $apList ($apList,[$splitFileLines $fileName]);
}
:foreach line in=$apList do={
  :put "Line: $line";
}
