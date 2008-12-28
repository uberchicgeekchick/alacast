#!/bin/tcsh -f
set podcatcher = "gpodder --add"
set podiobooks_opml = "./Apps/Alacast/Podcasts/OPMLs/Podnovels/Podiobooks.com.opml"
if ( "${?1}" == "1" && -e "${1}" ) set podiobooks_opml = "${1}"
foreach podiobook ( `/usr/bin/grep --perl-regex 'xmlUrl=["'\''][^"'\'']+["'\'']' "${podiobooks_opml}" | /usr/bin/sed 's/.*xmlUrl=["'\'']\(http[^"'\'']\+\)["'\''].*/\1/g'` )
	printf "Checking: %s\n" "${podiobook}"
	wget --quiet -O podiobook.xml "${podiobook}"
	set is_finished = `/usr/bin/grep 'theend.mp3' podiobook.xml`
	if ( "${is_finished}" != "" ) then
		printf "\t[finished]\n"
		continue
	endif
	printf "\t[unfinished]\nPlease wait while I subscribe to this podiobook.\n"
	${podcatcher}="${podiobook}" > & /dev/null
end
if ( -e podiobook.xml ) rm podiobook.xml
