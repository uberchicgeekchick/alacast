#!/bin/tcsh
if ( "${?1}" == "0" || ! -x "${1}" ) then
	printf "Usage: %s [opml_file]" $0
	exit -1
endif

# grep 'xmlUrl=["'\'']http' Online\ Television.opml | cut -d= -f5 | cut -d\' -f2
foreach podcast ( `grep 'xmlUrl=["'\''http' "${1}" | sed --regexp-extended "s/.*xmlUrl='([^']+)'.*/\1/"` )
	gpodder --add="${1}"
end
