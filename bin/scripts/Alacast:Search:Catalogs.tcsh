#!/bin/tcsh -f
if ( ! ( "${?1}" != "0" && "${1}" != "" ) ) goto usage

cd `dirname "${0}"`/../../data/opml

set be_verbose = "FALSE"
if ( "${1}" == "--verbose" ) then
	set be_verbose = "TRUE"
	shift
endif

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

set search_for = ""
switch ( "${2}" )
case "title":
case "htmlUrl":
case "text":
case "description":
	set search_for = "${2}"
	breaksw
case "xmlUrl":
default:
	set search_for = "xmlUrl"
	breaksw
endsw
set catalogs = ( "IP.TV" "Library" "Podcasts" "Vodcasts" "Radiocasts" )

foreach catalog ( ${catalogs} )
	foreach opml_and_outline ( "`/usr/bin/grep --binary-files=without-match --with-filename -ri --perl-regex -e '^[\t\ ]+<outline.*${attrib}=["\""'\''].*${value}.*["\""'\'']' '${catalog}'`" )
		if ( "${be_verbose}" == "TRUE" ) then
			printf "The %s you're searching for was found in:\n\t" "${attrib}"
			printf "%s" "${opml_and_outline}" | cut -d'	' -f1 | sed 's/:$//g'
			printf "\tIt's %s's value is: " "${search_for}"
		endif
		printf "%s" "${opml_and_outline}" | sed "s/.*${search_for}=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/"

		if ( "${be_verbose}" == "TRUE" ) printf "\n"
		printf "\n"
	end
end

exit

usage:
	printf "Usage| %s [--verbose] [--title|(default)xmlUrl|htmlUrl|text|description]='[search_term]' [attribute-to-display. default: xmlUrl]\n" `basename "${0}"`
	exit

