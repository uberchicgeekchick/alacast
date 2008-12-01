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

printf "Downloading podcast's feed.\n"
wget --quiet -O episodes.xml `echo "${1}" | sed '+s/\?/\\\?/g'`

set title = `/usr/bin/grep '<title.*>' episodes.xml | sed 's/<\!\[CDATA\[\(.*\)\]\]>/\1/' | sed 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/' | head -1 | sed 's/^[\s\t]\+\(.*\)[\s\t]*$/\1/g' | sed 's/[\r\n]//g'`
printf "\n\tDownloading all episodes of %s\n" "${title}"
if ( ! -d "${title}" ) mkdir -p "${title}"

#set titles = `/usr/bin/grep '<title.*>' episodes.xml | sed 's/<\!\[CDATA\[\(.*\)\]\]>/\1/' | sed 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/'`
#foreach title ( $titles )
#	echo "-->${title}<--"
#end
#printf "%s" ${titles}
#exit

set episodes = `/usr/bin/grep 'enclosure' episodes.xml | sed '+s/.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed 's/.*href=["'\'']\([^"'\'']*\).*/\1/g' | sed '+s/\?/\\\?/g'${limit_episodes}`

set total_episodes = `/usr/bin/grep 'enclosure' episodes.xml | sed '+s/.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed 's/.*href=["'\'']\([^"'\'']*\).*/\1/g' | sed '+s/\?/\\\?/g' | wc -l`


printf "Found %s total episodes\n" "${total_episodes}"

foreach episode ( $episodes )
	set episodes_filename = `basename ${episode}`
	switch ( `printf '%s' "${episodes_filename}" | sed 's/.*\.\([^.]*\)$/\1/'` )
	case "pdf":
		goto skip_episode
	endsw

#	if ( -e "${episodes_filename}" ) then
#		echo "Skipping ${episodes_filename}"
#		continue
#	endif

	switch ( "${episodes_filename}" )
	case -e: case "theend.mp3": case "caughtup.mp3": case "caught_up_1.mp3":
		goto skip_episode
	endsw

	set is_commentary = `echo "${episodes_filename}" | sed 's/.*\([Cc]ommentary\).*/\1/'`
	switch ( "${is_commentary}" )
	case "Commentary": case "commentary":
		goto skip_episode
	endsw

	printf "\n\tDownloading episode: %s\n" "${episodes_filename} "

	wget --quiet -O "${title}/${episodes_filename}" "${episode}"
	printf "\t\t\t["
	if ( ! -e "${title}/${episodes_filename}" ) then
		printf "*epic fail*?"
	else
		printf "*w00t*, FTW!"
	endif
	printf "]\n"
	next_episode:
end

echo "*w00t\!*, I'm done; enjoy online media at its best!"

rm episodes.xml

exit

skip_episode:
printf "\n\tSkipping ${episodes_filename}"
goto next_episode

