#!/bin/tcsh
if ( "${?1}" == "0" ) then
	printf "Usage: %s [search term]" $o
	exit -1
endif

search:
foreach set_episode_info ( `gPodder:Search-indexes.tcsh "${1}" | sed 's/^.*<title>\(.\+\)<\/title>.*<url>\(.\+\)<\/url>.*$/set url = "\2" ; set title = "\1"/'` )
	eval $set_episode_info
	wget -O "${title}" "${url}"
end

shift
if ( "${?1}" != "0" && "${1}" != "" ) goto search

