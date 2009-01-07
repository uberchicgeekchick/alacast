#!/bin/tcsh -f
set action = ""
if ( "${?1}" != "0" && "${1}" != "" ) then
	switch ( "${1}" )
	case '--delete':
	case '--unsubscribe':
		shift
		set action = "del"
		breaksw
	case '--add':
	case '--subscribe':
		shift
		set action = "add"
		breaksw
	endsw
endif

if ( "${?1}" == "0" || "${1}" == "" || ! -e "${1}" ) then
	printf "Usage: %s OPML_file"
	exit
endif

cd `dirname "${0}"`/../../
foreach opml ( "`find . -iname '*.opml'`" )
	/usr/bin/grep --perl-regexp -e '^[\t\ \s]+<outline.*xmlUrl=["\""'\''][^"\""'\'']+["\""'\'']' "${1}" | sed 's/^[\ \s\t]\+<outline.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/g' >! ./.alacast.podcasts.lst

	if ( "${action}" == "" ) then
		cat ./.alacast.podcasts.lst
		rm ./.alacast.podcasts.lst
	continue
	endif

	foreach podcast ( "`cat ./.alacast.podcasts.lst`" )
		printf "Adding:\n\t %s" "${podcast}"
		set result = "`gpodder --${action}='${podcast}' | sed 's/^\([A-Z]\)/\1/'`"
		printf "\t\t["
		switch ( "${result}" )
		case "A":
			printf "added"
			breaksw
		case "D":
			printf "deleted"
			breaksw
		case "E":
			printf "error"
		 	breaksw
		default:
			printf "unknown]\n\t[message:%s" "${result}"
			breaksw
		endsw
		printf "]\n\n"
	end
end

if ( -e "./.alacast.podcasts.lst" ) rm ./.alacast.podcasts.lst

