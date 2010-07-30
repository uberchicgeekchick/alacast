#!/bin/tcsh -f
if(! ${?0} ) then
	printf "**error:** This script cannot be sourced." > /dev/stderr;
	exit -1;
endif

if(!( ${?1} && "${1}" != "" && "${1}" != "--help")) then
	goto usage
endif
unsetenv GREP_OPTIONS;
	

next_option:
while( ${?1} && "${1}" != "" )
	set action="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)/\1/g'`";
	set equals="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)/\2/g'`";
	set opml="`printf "\""%s"\"" "\""${1}"\"" | sed -r 's/\-\-([^=]+)(=?)(.*)/\3/g'`";
	
	if( "${opml}" == "" && "${equals}" == "" && "${2}" != "" && -e "${2}" ) then
		set opml="${2}";
		shift;
	endif
	
	shift;
	switch ( "${action}" )
		case 'h':
		case "help":
			goto usage;
			breaksw;
		
		case "command":
			set message="Running:\t${opml}\tto parse & process:";
			set exec="${opml}";
			continue;
		
		case "fetch":
			set message="Fetching:";
			set exec="alacast:feed:fetch:all:enclosures.tcsh --disable=logging --xmlUrl";
			breaksw;
		
		case "del":
		case "delete":
		case "unsubscribe":
			set message="Deleting:";
			set exec="gpodder --del";
			breaksw;
		
		case "add":
		case "subscribe":
			set message="Adding:";
			set exec="gpodder --add";
			breaksw;
		
		default:
			printf "%s is not supported\t\t[skipped]\n" `printf "%s" "${action}" | sed -r 's/[e]?$/ing/'`;
			breaksw;
		
	endsw

	foreach podcast("`/usr/bin/grep --perl-regexp --ignore-case '^[\t\ \s]+<outline.*xmlUrl=["\""'\''][^"\""'\'']+["\""]' "\""${opml}"\"" | sed --regexp-extended 's/^[\ \s\t]+<outline.*xmlUrl=["\""'\'']([^"\""'\'']+)["\""'\''].*/\1/ig'`")
		if( ${?message} ) then
			printf "%s\t <%s>\n\t\t\t" "${message}" "${podcast}";
		endif
		( $exec="${podcast}" > /dev/stdout ) >& /dev/stderr;
		if( "${status}" == "0" ) then
			printf "[succeeded]";
		else
			printf "[failed]";
		endif
		printf "\n";
	end
	unset opml;
end

exit 0;

usage:
	printf "Usage: %s --[add|subscribe|unsubscribe|delete]=OPML_file" "`basename "\""${0}"\""`";
	if(! ${?action} ) \
		exit -1;
	goto next_option;
