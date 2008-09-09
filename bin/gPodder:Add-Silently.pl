#!/bin/tcsh
if ( "${1}" == "0" ) then
	printf "Usage: %s URI"
	exit -1
endif

/usr/bin/gpodder --add="${1}" >& /dev/null &

