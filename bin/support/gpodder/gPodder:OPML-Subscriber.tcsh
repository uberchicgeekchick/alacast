#!/bin/tcsh -f
if ( "${?1}" == "0" && "${1}" == "" && -e "${1}" ) then
	printf "Usage: %s OPML_file"
	exit
endif

/usr/bin/grep --perl-regexp -e 'xmlUrl=["'\''][^"'\'']+["'\'']' "${1}" | sed 's/.*xmlUrl=["'\'']\([^"'\'']\+\)["'\''].*/\1/g' >! .alacast.opml.dump.lst

foreach podcast ( "`cat .alacast.opml.dump.lst`" )
	printf "Adding:\n\t %s" "${podcast}"
	set testing_add = `gpodder --add="${podcast}"`
	set testing_add = `echo ${testing_add} | sed 's/^\([ADE]\)/\1/g'`
	printf "\t\t["
	switch ( "${testing_add}" )
	case "A":
		printf "added"
		breaksw
	case "D":
		printf "deleted"
		breaksw
	case "E":
		printf "error"
		breaksw
	endsw
	printf "]\n\n"
end

rm .alacast.opml.dump.lst
