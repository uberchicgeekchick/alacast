#!/bin/tcsh
if ( "${?1}" == "0" ) then
	printf "Usage: %s RSS_URI\n" `basename ${0}`
	exit 1
endif

set limit_episodes = ""
if ( "${?2}" == "1" ) then
	if ( ${2} >= 1 ) set limit_episodes = " | head -${2}"
endif

echo "Downloading podcast's feed."
wget --quiet -O episodes.xml `echo "${1}" | sed '+s/\?/\\\?/g'`

foreach episode ( `grep --regexp 'enclosure.*url=' episodes.xml | sed '+s/^.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed '+s/\?/\\\?/g'${limit_episodes}` )
	set episodes_filename = `basename ${episode}`

	if ( -e "${episodes_filename}" ) then
		echo "Skipping ${episodes_filename}"
	else
		echo -n "Downloading episode:\n\t${episodes_filename}\n\t"

		wget --quiet -O "${episodes_filename}" "${episode}"
	
		if( -e "${episodes_filename}" ) then
			echo "done\n"
		else
			echo "failed\n"
		endif
	endif
end

echo "*w00t*, I'm done; have fun girl!\n\n&Remember: I ^created^, *coded*, &_wrote_ this!  I am an uberChick!\nYou go girl!  I can do this!"

rm episodes.xml
