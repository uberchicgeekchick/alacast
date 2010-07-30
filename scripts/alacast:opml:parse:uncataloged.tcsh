#!/bin/tcsh -f
if ( ! ( "${?1}" == "1" && -e "${1}" ) ) then
	printf "Usage: %s OPML_file.opml\n" `basename ${0}`
	exit
endif

source `dirname "${0}"`/alacast:catalogs:load.tcsh

while ( "${?1}" == "1" && "${1}" != "" )
	foreach podcast_uri ( "`/usr/bin/grep -r --perl-regex -e '^[\ \s\t]+<outline.*xmlUrl=["\""'\''][^"\""'\'']+["\""'\''].*\/>' '${1}' | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/g' | sed 's/\(&amp;\)/\&/g' | sed 's/\([?+]\)/\\\1/g'`" )
		set found_podcast = "FALSE"
		foreach podcast_catalog ( ${catalogs} )
			set result = ""
			foreach result ( "`/usr/bin/grep -r --perl-regex -e 'xmlUrl=["\""'\'']${podcast_uri}[^"\""'\'']*["\""'\'']' '${podcast_catalog}' | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/g' | sed 's/\([?&+]\)/\\\1/g'`" )
				if ( "${result}" != "" ) then
					set found_podcast = "TRUE"
					break
				endif
			end
		end
		if ( "${found_podcast}" == "FALSE" ) then
			# printf cannot be used here in case the uri includes uri hex codes
			/usr/bin/grep -r --perl-regex -e "^[\ \s\t]+<outline.*xmlUrl=["\""'\'']${podcast_uri}[^"\""'\'']*["\""'\''].*\/>" "${1}"
		endif
	end
	shift
end
