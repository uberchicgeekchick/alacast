#!/bin/tcsh -f
if ( "${?1}" == "0" || "${1}" == "" || ! -e "${1}" ) then
	printf "Usage: %s [--del|--delete|--unsubscribe|--add|--subscribe]"
	exit
endif

set action = ""
if ( "${?1}" != "0" && "${1}" != "" ) then
	switch ( "${1}" )
	case "--del":
	case '--delete':
	case '--unsubscribe':
		shift
		set message = "Delet"
		set action = "del"
		breaksw
	case '--add':
	case '--subscribe':
		shift
	default:
		set message = "Add"
		set action = "add"
		breaksw
	endsw
endif

source `dirname "${0}"`/alacast:catalogs:load.tcsh

foreach podcast_catalog ( ${catalogs} )
	foreach opml ( "`find './${podcast_catalog}' -iname '*.opml'`" )
		/usr/bin/grep --perl-regexp -e '^[\t\ \s]+<outline.*xmlUrl=["\""'\''][^"\""'\'']+["\""'\'']' "${opml}" | sed 's/^[\ \s\t]\+<outline.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/g' >! ./.alacast.podcasts.lst

		if ( "${action}" == "" ) then
			cat ./.alacast.podcasts.lst
			rm ./.alacast.podcasts.lst
			continue
		endif

		foreach podcast ( "`cat ./.alacast.podcasts.lst`" )
			printf "%sing:\n\t %s" "${message}" "${podcast}"
			gpodder --"${action}"="${podcast}"
		end
	end
end

if ( -e "./.alacast.podcasts.lst" ) rm ./.alacast.podcasts.lst

