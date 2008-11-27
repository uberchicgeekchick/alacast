#!/bin/tcsh -f
if ( "${?1}" == "0" && "${1}" == "" && -e "${1}" ) then
	printf "Usage: %s OPML_file"
	exit
endif

foreach podcast ( "`grep -e xmlUrl=\[\"\']\[^\"\']+ "${1}" | sed 's/.*xmlUrl=["'\'']\([^"'\'']\+\)['\''"].*/\1/'"` )
	printf "Adding:\n\t %s" "${podcast}"
	gpodder --add="${podcast}"
	printf "\n\n"
end
