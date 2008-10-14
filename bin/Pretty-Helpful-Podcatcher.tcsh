#!/bin/tcsh
set what_to_output = "default"

set limit_episodes = ""

if ( "${?1}" == "0" ) then
	printf "Usage: %s RSS_URI\n" `basename ${0}`
	exit 1
else
	switch ( "${1}" )
		case "--silent":
			set what_to_output = "nothing"
		breaksw
		case "--quiet":
			set what_to_output = "very_lil"
		breaksw
		case "--verbose":
			set what_to_output = "everything"
		breaksw
		case "--dl_newest_only":
			set limit_episode = " | head -1"
		breaksw
	endsw
	shift
endif

if ( "${?2}" == "1" ) then
	if ( ${2} >= 1 ) set limit_episodes = " | head -${2}"
endif

echo "Downloading podcast's feed."
wget --quiet -O episodes.xml `echo "${1}" | sed '+s/\?/\\\?/g'`

foreach episode ( `grep --regexp 'enclosure.*url=' episodes.xml | sed '+s/^.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed '+s/\?/\\\?/g'${limit_episodes}` )
	set episodes_filename = `basename ${episode}`

	if ( -e "${episodes_filename}" ) then
		echo "Skipping ${episodes_filename}"
		continue
	endif

	switch ( "${episodes_filename}" )
		case "theend.mp3":
		case "caughtup.mp3":
			echo "Skipping ${episodes_filename}"
		breaksw

		default:
			echo -n "Downloading episode:\n\t${episodes_filename}\n\t"

			wget --quiet -O "${episodes_filename}" "${episode}"
	
			if( -e "${episodes_filename}" ) then
				echo "done\n"
			else
				echo "failed\n"
			endif
		breaksw
	endsw
end

echo "*w00t*, I'm done; have fun girl!\n\n&Remember: I ^created^, *coded*, &_wrote_ this!  I am an uberChick!\nYou go girl!  I can do this!"

rm episodes.xml
