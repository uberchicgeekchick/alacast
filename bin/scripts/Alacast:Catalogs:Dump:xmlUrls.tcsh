#!/bin/tcsh -f
set action = ""
if ( "${?1}" != "0" && "${1}" != "" ) then
	switch ( "${1}" )
	case '--delete':
	case '--unsubscribe':
		shift
		set message = "Delet"
		set action = "del"
		breaksw
	case '--add':
	case '--subscribe':
		shift
		set message = "Add"
		set action = "add"
		breaksw
	endsw
endif

if ( "${?1}" == "0" || "${1}" == "" || ! -e "${1}" ) then
	printf "Usage: %s OPML_file"
	exit
endif

cd `dirname "${0}"`/../../data/opml
source set_catalogs.tcsh

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

