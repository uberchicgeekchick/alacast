#!/bin/tcsh -f
if ( "${?1}" == "0" || "${1}" == "" ) goto usage

printf "${cwd}"

source `dirname "${0}"`/alacast:catalogs:load.tcsh

set attrib="`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`"
set value="`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`"

if ( ! ( "${attrib}" != "" && "${value}" != "" ) ) goto usage

switch ( "${attrib}" )
case "title":
case "xmlUrl":
case "htmlUrl":
case "text":
case "description":
	breaksw
default:
	goto usage
	breaksw
endsw

foreach catalog( ${catalogs} )
	foreach podcasts_xmlUrl( "`/usr/bin/grep --binary-files=without-match -ri --perl-regex -e '${attrib}=["\""'\''].*${value}.*["\""'\'']' '${catalog}' | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/'`" )
		goto get_newest;
		find_next_newest:
	end
end

exit

usage:
	printf "Usage| %s --[title|xmlUrl|htmlUrl|text|description]='[search_term]'\n" "`basename "\""${0}"\""`";
	exit;

wget_newest:
	if ( -e .newest.feed.xml ) rm -f .newest.feed.xml
	wget -O .newest.feed.xml --quiet "${podcasts_xmlUrl}"
	set title="`grep '<title.*>.*<\/title>' .newest.feed.xml | head -3 | tail -1 | sed 's/<title.*>\([^<]\+\)<\/title>/\1/g'`"
	set enclosure="`grep '<enclosure.*>' .newest.feed.xml | head -1 | sed 's/<enclosure.*url=["\""]\([^"\""]\+\)["\""].*>/\1/g'`"
	if ( -e .newest.feed.xml ) rm -f .newest.feed.xml
	goto find_next_newest

