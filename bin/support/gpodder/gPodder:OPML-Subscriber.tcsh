#!/bin/tcsh -f
if ( "${?1}" == "0" && "${1}" == "" ) then
	printf "Usage: %s [search_term]"
	exit
endif

foreach podcast ( `grep -e xmlUrl=\[\"\']\[^\"\']+ "${opml_file}" | sed 's/.*xmlUrl=["'\'']\([^"'\'']\+\)['\''"].*/\1/'` )
	gpodder --add="${podcast}"
end
