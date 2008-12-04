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
wget --quiet -O './00-episodes.xml' `echo "${1}" | sed '+s/\?/\\\?/g'`

# Grabs the titles of the podcast and all episodes.
cp './00-episodes.xml' './00-titles.lst'
ex '+1,$s/[\r\n]*//g' '+1,$s/<\/\(item\|entry\)>/\<\/\1\>\r/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*\(enclosure\).*<\/\(item\|entry\)>$/\2/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<\/\(item\|entry\)>[\n]\+//ig' '+1,$s/\&\(\#8217\|\#039\|rsquo\|lsquo\)\;/g'\''/ig' '+1,$s/\&[^\;]\+\;[\ \t\s]*//g' '+$d' '+wq' './00-titles.lst'

set title = "`/usr/bin/grep '<title.*>' './00-episodes.xml' | sed 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/g' | head -1 | sed 's/[\r\n]//g'`"
if ( ! -d "${title}" ) mkdir -p "${title}"

cp './00-titles.lst' './00-episodes.xml' "./${title}"

set download_log = "${title}/00-"`basename "${0}"`".log"
if ( ! -e "${download_log}" ) touch "${download_log}"

set episodes = `/usr/bin/grep 'enclosure' './00-episodes.xml' | sed '+s/.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed 's/.*href=["'\'']\([^"'\'']*\).*/\1/g' | sed 's/^\(http:\/\/\).*\(http:\/\/.*$\)/\2/g' | sed '+s/\?/\\\?/g'${limit_episodes}`

printf "\n\tI have found %s episodes of:\n\t\t'%s'\n" "${#episodes}" "${title}"

foreach episode ( $episodes )
	# This removes redirection & problems it causes.
	set episodes_filename = `basename "${episode}"`
	set episodes_title = "`cat './00-titles.lst' | head -1 | sed 's/[\r\n]//g'`"
	ex -s '+1d' '+wq' './00-titles.lst'

	set extension = `printf '%s' "${episodes_filename}" | sed 's/.*\.\([^.]*\)$/\1/'`
	switch ( "${extension}" )
	case "pdf":
		goto skip_episode
		breaksw
	endsw

	if ( -e "${title}/${episodes_title}.${extension}" ) goto skip_episode

	switch ( "${episodes_filename}" )
	case "theend.mp3": case "caughtup.mp3": case "caught_up_1.mp3":
		goto skip_episode
		breaksw
	endsw

	set is_commentary = `echo "${episodes_filename}" | sed 's/.*\([Cc]ommentary\).*/\1/'`
	switch ( "${is_commentary}" )
	case "Commentary": case "commentary":
		goto skip_episode
		breaksw
	endsw

	set download_message = `printf "Downloading episode: %s\n\t\tURL: %s\n\n" \
				"${episodes_title}" "${episode}"`;
	printf "%s" "${download_message}" >> "${download_log}";
	printf "%s" "${download_message}"

	wget --quiet -O "${title}/${episodes_title}.${extension}" "${episode}"
	printf "\t\t\t["
	if ( ! -e "${title}/${episodes_title}.${extension}" ) then
		printf "*epic fail*?"
	else
		printf "*w00t*, FTW!"
	endif
	printf "]\n"
	next_episode:
end

printf "*w00t\!*, I'm done; enjoy online media at its best!\a"

rm './00-episodes.xml'
rm './00-titles.lst'
exit

skip_episode:
printf "\n\tSkipping ${episodes_filename}"
goto next_episode

