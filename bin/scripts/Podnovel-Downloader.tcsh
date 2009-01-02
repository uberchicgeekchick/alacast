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

set feed_type = "rss"
if ( "`/usr/bin/grep -i '<channel' './00-feed.xml'`" == "" ) then
	set feed_type = "atom"
endif


# Grabs the titles of the podcast and all episodes.
cp './00-feed.xml' './00-titles.lst'
ex '+1,$s/[\r\n]*//g' '+1,$s/<\/\(item\|entry\)>/\<\/\1\>\r/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*\(enclosure\).*<\/\(item\|entry\)>$/\2/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<\/\(item\|entry\)>[\n\r]*//ig' '+$d' '+wq' './00-titles.lst'
ex '+1,$s/&\(#038\|amp\)\;/\&/ig' '+1,$s/&\(#8243\|#8217\|#8220\|#8221\|\#039\|rsquo\|lsquo\)\;/'\''/ig' '+1,$s/&[^;]\+\;[\ \t]*//ig' '+1,$s/<\!\[CDATA[\(.*\)\]\]>/\1/g' '+1,$s/#//g' '+1,$s/\//\ \-\ /g' '+wq' './00-titles.lst'

# This will be my last update to any part of Alacast v1
# This fixes episode & chapter titles so that they will sort correctly
ex '+1,$s/\(Zero\)/0/gi' '+1,$s/\(One\)/1/gi' '+1,$s/\(Two\)/2/gi' '+1,$s/\(Three\)/3/gi' '+1,$s/\(Four\)/4/gi' '+1,$s/\(Five\)/5/gi' '+wq' './00-titles.lst'
ex '+1,$s/\(Six\)/6/gi' '+1,$s/\(Seven\)/7/gi' '+1,$s/\(Eight\)/8/gi' '+1,$s/\(Nine\)/9/gi' '+1,$s/\(Ten\)/10/gi' '+wq' './00-titles.lst'

ex '+1,$s/\([0-9]\)ty/\10/gi' '+1,$s/(Fifty)/50/gi' '+1,$s/(Thirty)/30/gi' '+1,$s/(Twenty)/20/gi' '+wq' './00-titles.lst'
ex '+1,$s/\([0-9]\)teen/1\1/gi' '+1,$s/(Fifteen)/15/gi' '+1,$s/(Thirteen)/13/gi' '+1,$s/(Twelve)/12/gi' '+1,$s/(Eleven)/11/gi' '+1,$s/(Ten)/10/gi' '+wq' './00-titles.lst'

ex '+1,$s/^\([0-9]\{1\}\)\([^0-9]\{1\}\)/0\1\2/' '+1,$s/\([^0-9]\{1\}\)\([0-9]\{1\}\)\([^0-9]\{1\}\)/\10\2\3/g' '+1,$s/\([^0-9]\{1\}\)\([0-9]\{1\}\)$/\10\2/' '+1,$s/\//\ \-\ /g' '+wq' './00-titles.lst'

# Grabs the enclosures from the feed.
# This 1st method only grabs one enclosure per item/entry.
cp '00-feed.xml' '00-enclosures-01.lst'
#ex '+1,$s/[\r\n]*//g' '+1,$s/<\/\(item\|entry\)>/\<\/\1\>\r/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<.*enclosure[^>]*\(url\|href\)=["'\'']\([^"'\'']\+\)["'\''][^>]*type=["'\'']\(audio\|video\).*<\/\(item\|entry\)>$/\4/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<\/\(item\|entry\)>[\n\r]*//ig' '+$d' '+wq' '00-enclosures-01.lst'
ex '+1,$s/[\r\n]*//g' '+1,$s/<\/\(item\|entry\)>/\<\/\1\>\r/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<.*enclosure[^>]*\(url\|href\)=["'\'']\([^"'\'']\+\)["'\''].*<\/\(item\|entry\)>$/\4/ig' '+1,$s/.*<\(item\|entry\)>.*<title[^>]*>\([^<]*\)<\/title>.*<\/\(item\|entry\)>[\n\r]*//ig' '+$d' '+wq' '00-enclosures-01.lst'
ex '+1,$s/^[\ \s\r\n]\+//g' '+1,$s/[\ \s\r\n]\+$//g' '+1,$s/\?/\\\?/g' '+wq' './00-enclosures-01.lst'

# This second method grabs all enclosures.
cp '00-feed.xml' '00-enclosures-02.lst'
/usr/bin/grep --perl-regex '.*<.*enclosure[^>]*>.*' './00-feed.xml' | sed 's/.*url=["'\'']\([^"'\'']\+\)["'\''].*type=["'\'']\(audio\|video\).*/\1/gi' | sed 's/.*<link[^>]\+href=["'\'']\([^"'\'']\+\)["'\''].*/\1/gi' | sed 's/^\(http:\/\/\).*\(http:\/\/.*$\)/\2/gi' | sed 's/<.*>[\r\n]\+//ig' | sed 's/\?/\\\?/gi' >! './00-enclosures-02.lst'
ex '+1,$s/^[\ \s\r\n]\+//g' '+1,$s/[\ \s\r\n]\+$//g' '+1,$s/\?/\\\?/g' '+wq' './00-enclosures-02.lst'

set enclosure_count_01 = `cat "./00-enclosures-01.lst"`
set enclosure_count_02 = `cat "./00-enclosures-02.lst"`
if ( ${#enclosure_count_01} >= ${#enclosure_count_02} ) then
	mv "./00-enclosures-01.lst" "./00-enclosures.lst"
	rm "./00-enclosures-02.lst"
else
	mv "./00-enclosures-02.lst" "./00-enclosures.lst"
	rm "./00-enclosures-01.lst"
endif

set title = "`/usr/bin/grep '<title.*>' './00-feed.xml' | sed 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/gi' | head -1 | sed 's/[\r\n]//g' | sed 's/\//\ \-\ /g'`"
if ( ! -d "${title}" ) mkdir -p "${title}"

if ( "${?2}" == "1" && "${2}" == "--debug" ) cp './00-titles.lst' './00-feed.xml' './00-enclosures.lst' "./${title}/"

set episodes = `cat './00-enclosures.lst'${limit_episodes}`

set download_log = "${title}/00-"`basename "${0}"`".log"
touch "${download_log}"

printf "\n\tI have found %s episodes of:\n\t\t'%s'\n\n" "${#episodes}" "${title}"
printf "\n\tI have found %s episodes of:\n\t\t'%s'\n\n" "${#episodes}" "${title}" >! "${download_log}"

foreach episode ( $episodes )
	set episode = `echo "${episode}" | sed 's/[\r\n]$//'`
	set episodes_filename = `basename ${episode}`
	set extension = `printf '%s' "${episodes_filename}" | sed 's/.*\.\([^.]*\)$/\1/'`

	set episodes_title = "`head -1 './00-titles.lst' | sed 's/[\r\n]//g' | sed 's/\?//g'`"
	if ( "${episodes_title}" == "" ) set episodes_title = `printf '%s' "${episodes_filename}" | sed 's/\(.*\)\.[^.]*$/\1/'`
	ex -s '+1d' '+wq' './00-titles.lst'

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
	case "theend.mp3":
	case "caughtup.mp3":
	case "caught_up_1.mp3":
		printf "[skipping podiobook.com notice]\n\n" >> "${download_log}"
		printf "[skipping podiobook.com notice]\n\n"
		continue
		breaksw
	endsw

	set is_commentary = `printf "${episodes_title}==${episodes_filename}" | sed 's/.*\([Cc]ommentary\).*/\1/gi'`
	if ( "${is_commentary}" != `printf "${episodes_title}==${episodes_filename}"` ) then
		printf "[skipped commentary track]\n\n" >> "${download_log}"
		printf "[skipped commentary track]\n\n"
		continue
	endif

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
