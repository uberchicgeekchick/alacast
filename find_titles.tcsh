#!/usr/bin/tcsh -f
#printf "Downloading podcast's feed.\n"
#wget --quiet -O "./episodes.xml" `echo "${1}" | sed '+s/\?/\\\?/g'`

# Grabs the titles of the podcast and all episodes.
cp "./episodes.xml" "./00-titles.lst"
ex '+1,$s/[\r\n]*//g' '+1,$s/<\/\(item\|entry\)>/\<\/\1\>\r/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*\(enclosure\).*<\/\(item\|entry\)>$/\2/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<\/\(item\|entry\)>[\n]\+//ig' '+1,$s/\&\(\#8217\|\#039\|rsquo\|lsquo\)\;/g'\''/ig' '+1,$s/\&[^\;]\+\;[\ \t\s]*//g' '+$d' '+wq' './00-titles.lst'

