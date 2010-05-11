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
	if( "${opml}" == "" && "${equals}" == "" && "${2}" != "" )	\
		set opml="${2}";
	shift;
	switch ( "${action}" )
	case 'delete':
	case 'unsubscribe':
		set message="Delet";
		set action="del";
		breaksw
	case 'add':
	case 'subscribe':
		set message="Add";
		set action="add";
		breaksw
	default:
		printf "%s is not supported\t\t[skipped]\n" `echo ${action} | sed --regexp-extended 's/[e]?$$/ing/`;
		goto usage
	endsw

	foreach podcast ( "`/usr/bin/grep --perl-regexp --ignore-case '^[\t\ \s]+<outline.*xmlUrl=["\""'\''][^"\""'\'']+["\""]' '${opml}' | sed --regexp-extended 's/^[\ \s\t]+<outline.*xmlUrl=["\""'\'']([^"\""'\'']+)["\""'\''].*/\1/ig'`" )
		printf "%sing:\t <%s>\n\t\t\t" "${message}" "${podcast}";
		( gpodder --${action}="${podcast}" > /dev/tty ) >& /dev/null;
		if( "${status}" == "0" ) then
			printf "[succeeded]";
		else
			printf "[failed]";
		endif
		printf "\n";
	end
end

exit 0;

usage:
	printf "Usage: %s --[add|subscribe|unsubscribe|delete]=OPML_file" "`basename '${0}'`";
	if(!( ${?action})) exit -1;
	goto next_option;
