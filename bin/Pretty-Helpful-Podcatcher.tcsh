#!/usr/bin/tcsh -f

set what_to_output = "default"

if ( "${?1}" == "0" || "${1}" == "" ) then
	printf "Usage: %s RSS_URI\n" `basename ${0}`
	exit -1
endif

set limit_episodes = ""
if ( "${?2}" == "1" && ${2} >= 1 ) then
	set limit_episodes = " | head -${2}"
else
	set limit_episodes = ""
endif

switch ( "${1}" )
	case "--silent":
		shift
		set what_to_output = "nothing"
	breaksw
	case "--quiet":
		shift
		set what_to_output = "very_lil"
	breaksw
	case "--verbose":
		shift
		set what_to_output = "everything"
	breaksw
	case "--newest":
		shift
		set limit_episodes = " | head -1"
	breaksw
	default:
	breaksw
endsw

# TODO
# I need to implement support for limiting how many enclosures are downloaded, maybe.
# I will actually prolly just drop this feature as I get closer to releasing Alacast 2.0 alapha.
set limit_episodes = ""

echo "Downloading podcast's feed."
wget --quiet -O episodes.xml `echo "${1}" | sed '+s/\?/\\\?/g'`

set title = `/usr/bin/grep -r '<title>' episodes.xml | sed 's/.*<title>\([^<]*\)<\/title>.*/\1/' | head -1 | sed 's/^[\s\t]\+\(.*\)[\s\t]*$/\1/g' | sed 's/[\r\n]//g'`
if ( ! -d "${title}" ) mkdir -p "${title}"

#et titles = `"grep -r '<title>' episodes.xml | sed 's/.*<title>\([^<]*\)<\/title>.*/\1\n/g' | sed 's/^[\s\t]\+\(.*\)[\s\t]*$/\1/g'"`
#oreach title ( $titles )
#echo "-->${title}<--"
#nd
#rintf "%s" ${titles}
#xit

set episodes = `/usr/bin/grep --regexp 'enclosure.*url=' episodes.xml | sed 's/\(<enclosure\)/\n\1/g' | sed '+s/.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed '+s/\?/\\\?/g'${limit_episodes}`

set total_episodes = `/usr/bin/grep --regexp 'enclosure.*url=' episodes.xml | sed 's/\(<enclosure\)/\n\1/g' | sed '+s/.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed '+s/\?/\\\?/g' | wc -l`


printf "Found %s total episodes\n" "${total_episodes}"

foreach episode ( $episodes )
	set episodes_filename = `basename ${episode}`

#	if ( -e "${episodes_filename}" ) then
#		echo "Skipping ${episodes_filename}"
#		continue
#	endif

	switch ( "${episodes_filename}" )
	case -e:
	case "theend.mp3":
	case "caughtup.mp3":
	case "caught_up_1.mp3":
		echo "Skipping ${episodes_filename}"
		continue
		breaksw
	endsw

	set is_commentary = `echo "${episodes_filename}" | sed 's/.*\([Cc]ommentary\).*/\1/'`
	switch ( "${is_commentary}" )
	case "Commentary":
	case "commentary":
		echo "Skipping commentary episode: ${episodes_filename}"
		continue
		breaksw
	endsw

	echo -n "Downloading episode: ${episodes_filename} "

	wget --quiet -O "${title}/${episodes_filename}" "${episode}"
	echo -n "\t\t"
	if( -e "${title}/${episodes_filename}" ) then
		echo "done\n"
	else
		echo "failed\n"
	endif
end

echo "*w00t\!*, I'm done; enjoy online media at its best!"

rm episodes.xml
