#!/bin/tcsh -f
if ( ! ( "${?1}" == "1" && -e "${1}" ) ) then
	printf "Usage: %s OPML_file.opml\n" `basename ${0}`
	exit
endif

set catalogs = ( "IP.TV" "Library" "Podcasts" "Vodcasts" )

while ( "${?1}" == "1" && "${1}" != "" )
	foreach podcast_uri ( "`/usr/bin/grep -r --perl-regex -e 'xmlUrl=["\""'\''][^"\""'\'']*["\""'\'']' '${1}' | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/g' | sed 's/\([?&+]\)/\\\1/g'`" )
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
			echo -n "${podcast_uri}\n" | sed 's/\\\([?&+]\)/\1/g'
			continue
		endif
	end
	shift
end
