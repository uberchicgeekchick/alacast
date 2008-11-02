#!/bin/tcsh
set add_or_del = ""
set podcast_list = ""
while ( "${add_or_del}" == "" )
	switch ( "${1}" )
	case -e:
		set podcast_list = "${1}"
		breaksw
	case "del":
		set add_or_del = "del"
		breaksw
	default:
		set add_or_del = "add"
		breaksw
	shift
	endsw
end

if ( "${podcast_list}" == "" || ! -e "${podcast_list}" ) then
	printf "Usage: %s [lists_of_podcasts]" `basename "${0}"`
	exit -1
endif

foreach podcast ( `cat "${podcast_list}"` )
	gpodder --"${add_or_del}"="${podcast}"
end

