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
wget --quiet -O ./episodes.xml `echo "${1}" | sed '+s/\?/\\\?/g'`

# Grabs the titles of the podcast and all episodes.
/usr/bin/grep '<title.*>' ./episodes.xml | sed 's/<\!\[CDATA\[\(.*\)\]\]>/\1/' | sed 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/' | sed 's/\&(\#8217|\#039|rsquo|lsquo)\;/'\''/g' | sed 's/\&[^\;]\+\;[\ \t\s]*//g' | sed 's/^[\ \s\t]\+\(.*\)[\ \s\t]\+$/\1/g' >! "./00-titles.lst"

set title = "`cat './00-titles.lst' | head -1 | sed 's/[\r\n]//g'`"
if ( ! -d "${title}" ) mkdir -p "${title}"

ex -s '+1,2d' '+wq' './00-titles.lst'

set download_log = "${title}/00-"`basename "${0}"`".log"
if ( ! -e "${download_log}" ) touch "${download_log}"

set episodes = `/usr/bin/grep 'enclosure' ./episodes.xml | sed '+s/.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed 's/.*href=["'\'']\([^"'\'']*\).*/\1/g' | sed 's/^\(http:\/\/\).*\(http:\/\/.*$\)/\2/g' | sed '+s/\?/\\\?/g'${limit_episodes}`
printf "\n\tDownloading %s episodes of %s\n" "${#episodes}" "${title}"

foreach episode ( $episodes )
	# This removes redirection & problems it causes.
	set episodes_filename = `basename ${episode}`
	set episodes_title = "`cat './00-titles.lst' | head -1 | sed 's/[\r\n]//g'`"
	ex -s '+1d' '+wq' './00-titles.lst'
	if ( "${episodes_title}" == "" ) set episodes_title = "`echo '${episodes_filename}' | sed 's/\(.*\)\.[^.]*$/\1/'`"

	printf "Episode: %s ( %s )\n\t\tURL: %s\n\n" \
		"${episodes_title}" "${episodes_filename}" "${episode}" \
		>> "${download_log}"

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

	download_episode:
	printf "\n\tDownloading episode:\n\t\t%s\n\t\t( %s )\n" "${episodes_title}" "${episodes_filename} "

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

rm ./episodes.xml
rm './00-titles.lst'
exit

skip_episode:
printf "\n\tSkipping ${episodes_filename}"
goto next_episode

