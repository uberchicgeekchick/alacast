#!/bin/tcsh
if ( "${?1}" == "0" ) then
	printf "Usage: %s [podcasts_URI]" $0
	exit -1
endif

wget -O feed.xml "${1}"

set episodes = ""



