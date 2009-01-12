#!/bin/tcsh -f
if ( ! ( "${?1}" != "0" && "${1}" != "" ) ) goto usage

cd `dirname "${0}"`/../../data/opml

set attrib = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\1/g'`"
set value = "`printf '${1}' | sed 's/\-\-\([^=]\+\)=\(.*\)/\2/g'`"

if ( ! ( "${attrib}" != "" && "${value}" != "" ) ) goto usage

switch ( "${attrib}" )
case "title":
case "xmlUrl":
case "htmlUrl":
case "text":
case "description":
	breaksw
case "help":
	goto usage
	breaksw
default:
	set attrib = "title"
	set value = "${1}"
	breaksw
endsw

set catalogs = ( "IP.TV" "Library" "Podcasts" "Vodcasts" )

foreach catalog ( ${catalogs} )
	/usr/bin/grep -r --perl-regex -e "${attrib}=["\""'\''].*${value}.*["\""'\'']" "${catalog}" | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/'
end

exit

usage:
	printf "Usage| %s --[title|xmlUrl|htmlUrl|text|description]='[search_term]' --xmlUrl[attribute-to-display]\n" `basename "${0}"`
	exit

