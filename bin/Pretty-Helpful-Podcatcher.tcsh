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
wget --quiet -O './00-feed.xml' `echo "${1}" | sed '+s/\?/\\\?/g'`

# Grabs the titles of the podcast and all episodes.
cp './00-feed.xml' './00-titles.lst'
ex '+1,$s/[\r\n]*//g' '+1,$s/<\/\(item\|entry\)>/\<\/\1\>\r/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*\(enclosure\).*<\/\(item\|entry\)>$/\2/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<\/\(item\|entry\)>[\n\r]*//ig' '+$d' '+wq' './00-titles.lst'
ex '+1,$s/&\(#038\|amp\)\;/\&/ig' '+1,$s/&\(#8243\|#8217\|#8220\|#8221\|\#039\|rsquo\|lsquo\)\;/'\''/ig' '+1,$s/&[^;]\+\;[\ \t]*//ig' '+1,$s/<\!\[CDATA[\(.*\)\]\]>/\1/g' '+1,$s/#//g' '+wq' './00-titles.lst'

set title = "`/usr/bin/grep '<title.*>' './00-feed.xml' | sed 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/g' | head -1 | sed 's/[\r\n]//g'`"
if ( ! -d "${title}" ) mkdir -p "${title}"

set download_log = "${title}/00-"`basename "${0}"`".log"
if ( ! -e "${download_log}" ) touch "${download_log}"

cp '00-feed.xml' '00-enclosures-01.lst'
ex '+1,$s/[\r\n]*//g' '+1,$s/<\/\(item\|entry\)>/\<\/\1\>\r/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<.*enclosure[^>]*\(url\|href\)=["'\'']\([^"'\'']\+\)["'\''].*<\/\(item\|entry\)>$/\4/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<\/\(item\|entry\)>[\n\r]*//ig' '+$d' '+wq' '00-enclosures-01.lst'
ex '+1,$s/[\r\n]\+$//g' '+1,$s/\?/\\\?/g' '+wq' './00-enclosures-01.lst'

cp '00-feed.xml' '00-enclosures-02.lst'
/usr/bin/grep 'enclosure' './00-feed.xml' | sed '+s/.*url[^"'\'']*.\([^"'\'']*\).*/\1/g' | sed 's/.*href=["'\'']\([^"'\'']*\).*/\1/g' | sed 's/^\(http:\/\/\).*\(http:\/\/.*$\)/\2/g' | sed 's/\?/\\\?/g' | sed 's/[\r\n]//g' >! './00-enclosures-02.lst'

set enclosure_count_01 = `cat "./00-enclosures-01.lst"`
set enclosure_count_02 = `cat "./00-enclosures-02.lst"`
if ( ${#enclosure_count_01} >= ${#enclosure_count_02} ) then
	mv "./00-enclosures-01.lst" "./00-enclosures.lst"
	rm "./00-enclosures-02.lst"
else
	mv "./00-enclosures-02.lst" "./00-enclosures.lst"
	rm "./00-enclosures-01.lst"
endif

cp './00-titles.lst' './00-feed.xml' './00-enclosures.lst' "./${title}"

set episodes = `cat './00-enclosures.lst'${limit_episodes}`

printf "\n\tI have found %s episodes of:\n\t\t'%s'\n\n" "${#episodes}" "${title}"

foreach episode ( $episodes )
	# This removes redirection & problems it causes.
	set episode = `echo "${episode}" | sed 's/[\r\n]$//'`
	set episodes_filename = `basename ${episode}`
	set extension = `printf '%s' "${episodes_filename}" | sed 's/.*\.\([^.]*\)$/\1/'`

	set episodes_title = "`head -1 './00-titles.lst' | sed 's/[\r\n]//g' | sed s/\'/\\\'/g`"
	if ( "${episodes_title}" == "" ) set episodes_title = `printf '%s' "${episodes_filename}" | sed 's/\(.*\)\.[^.]*$/\1/'`
	ex -s '+1d' '+wq' './00-titles.lst'

#	set numbers = ( "Zero\|0=00" "One\|1=01" "Two\|2=02" "Three\|3=03" "Four\|4=04" "Five\|5=05" "Six\|6=06" "Seven\|7=07" "Eight\|8=08" "Nine\|9=09" )
#	foreach number ( "${numbers}" )
#		set regex = `printf "${number}" | cut -d'=' -f1`
#		set replace = `printf "${number}" | cut -d'=' -f2`
#		set episodes_title = "`echo '${episodes_title}' | sed 's/\ \(${regex}\)/\ ${replace}/g' | sed s/\'/\\\'/g`"
#	end

	printf "\n\n\t\tFound episode: %s\n\t\tTitle: %s\n\t\tURL: %s\n\t\t\t" "${episodes_filename}" "${episodes_title}" "${episode}" \
		;
	printf "\n\n\t\tFound episode: %s\n\t\t%s\n\t\tURL: %s\n\t\t\t" "${episodes_filename}" "${episodes_title}" "${episode}" \
	       	>> "${download_log}"

	switch ( "${extension}" )
	case "pdf":
		printf "[skipping pdf]\n\n" >> "${download_log}"
		printf "[skipping pdf]\n\n"
		continue
		breaksw
	endsw

	# Skipping existing files.
	if ( -e "${title}/${episodes_title}.${extension}" ) then
		printf "[skipping existing file]\n\n" >> "${download_log}"
		printf "[skipped existing file]\n\n"
		continue
	endif
	
	switch ( "${episodes_filename}" )
	case "theend.mp3": case "caughtup.mp3": case "caught_up_1.mp3":
		printf "[skipping podiobook.com notice]\n\n" >> "${download_log}"
		printf "[skipping podiobook.com notice]\n\n"
		continue
		breaksw
	endsw

	set is_commentary = `echo "${episodes_filename}" | sed 's/.*\([C|c]ommentary\).*/\1/gi'`
	switch ( "${is_commentary}" )
	case "Commentary": case "commentary":
		printf "[skipped commentary track]\n\n" >> "${download_log}"
		printf "[skipped commentary track]\n\n"
		continue
		breaksw
	endsw

	wget --quiet -O "${title}/${episodes_title}.${extension}" "${episode}"
	if ( ! -e "${title}/${episodes_title}.${extension}" ) then
		printf "[*epic fail* :(]\n\n" >> "${download_log}"
		printf "[*epic fail* :(]\n\n"
	else
		printf "[*w00t\!*, FTW\!]\n\n" >> "${download_log}"
		printf "[*w00t\!*, FTW\!]\n\n"
	endif
end

printf "*w00t\!*, I'm done; enjoy online media at its best!"

rm './00-feed.xml' './00-titles.lst' './00-enclosures.lst'

