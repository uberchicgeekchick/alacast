#!/bin/tcsh -f
if ( "${?1}" == "0" && "${1}" == "" && -e "${1}" ) then
	printf "Usage: %s OPML_file"
	exit
endif

grep -e xmlUrl=\[\"\']\[^\"\']+ OPMLs/Audio\ Dramas/Studios/Darker\ Projects.opml | sed 's/.*xmlUrl=["'\'']\([^"'\'']\+\)['\''"].*/\1/' >! .alacast.opml.dump.lst

foreach podcast ( "`cat .alacast.opml.dump.lst`" )
	printf "Adding:\n\t %s" "${podcast}"
	gpodder --add="${podcast}"
	printf "\n\n"
end

rm .alacast.opml.dump.lst
