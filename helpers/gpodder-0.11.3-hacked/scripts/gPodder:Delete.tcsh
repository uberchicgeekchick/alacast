#!/bin/tcsh -f
if(!(${?1} && "${1}" != "" && "${1}" != "--help")) goto usage

set attrib="`printf "\""%s"\"" "\""${1}"\"" | sed 's/\-\-\([^=]\+\)\(=?\)\(.*\)/\1/g'`"
set equals="`printf "\""%s"\"" "\""${1}"\"" | sed 's/\-\-\([^=]\+\)\(=?\)\(.*\)/\2/g'`"
set value="`printf "\""%s"\"" "\""${1}"\"" | sed 's/\-\-\([^=]\+\)\(=?\)\(.*\)/\3/g' | sed -r "\""s/(['])/\1\\\1\1/g"\""`";
if( "${equals}" == "" && "${value}" == "" && "${2}" != "" )	\
	set value="`printf "\""%s"\"" "\""${2}"\"" | sed -r "\""s/(['])/\1\\\1\1/g"\""`";

if(!( "${attrib}" != "" && "${value}" != "" )) goto usage

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

foreach podcast ( "`/usr/bin/grep --line-number -i --perl-regex -e '${attrib}=["\""].*${value}.*["\""]' '${HOME}/.config/gpodder/channels.opml' | sed 's/.*xmlUrl=["\""'\'']\([^"\""'\'']\+\)["\""'\''].*/\1/' | sed 's/\(&\)amp;/\1/g'`" )
	printf "Deleting: %s\n" "${podcast}"
	( gpodder --del="${podcast}" > /dev/tty ) >& /dev/null
end

exit

usage:
	printf "Usage: %s --[title|xmlUrl|htmlUrl|text|description]='[search_term]'\n" `basename "${0}"`
	exit
