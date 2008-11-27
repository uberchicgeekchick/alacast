#!/bin/tcsh -f
if ( "${?1}" == "0" && "${1}" == "" ) then
	printf "Usage: %s [search_term]"
	exit
endif

foreach podcast ( `grep -r "${1}" "${HOME}/.config/gpodder/channels.opml" | sed 's/.*xmlUrl="\([^"]\+\)".*/\1/'` )
	gpodder --del="${podcast}"
end
