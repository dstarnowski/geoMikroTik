#Downloader for all script files for the project listed in the filelist file.
:local user "startik";
:local project "geoMikroTik";
:local branch "devel";

:local fileList "filelist.txt";
:local subdir "source";

:local url "https://raw.githubusercontent.com/$user/$project/$branch/$subdir";
/tool fetch mode=https url="$url/$fileList";
:delay 1s;
:local position 0;
:local list [/file get [/file find name="$fileList"] contents];
:do {
  :local space [:find $list " " $position];
  :if ([:len $space]>0) do={
    :if (($space-$position)>3) do={
      :local fileName [:pick $list $position $space];
      /tool fetch mode=https url="$url/$fileName";
    }
    :set $position ($space+1);
  } else={
    :if (([:len $list]-$position)>3) do={
      :local fileName [:pick $list $position [:len $list]];
      /tool fetch mode=https url="$url/$fileName";
    }
    :set $position 0;
  }
} while=($position>0);
